"""Tests for external-implementer. Fast cases use the built-in fake backend (no model, no quota).
Run:   python3 ~/.dotfiles/claude/scripts/test_external_implementer.py
Live:  EXTERNAL_IMPLEMENTER_LIVE=1 python3 ... (one tiny real Codex task, costs a sliver of quota)"""
import json, os, subprocess, tempfile, unittest

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "external-implementer")


def git(repo, *args):
    return subprocess.run(["git", *args], cwd=repo, capture_output=True, text=True, check=True).stdout


def make_repo():
    repo = tempfile.mkdtemp(prefix="ext-impl-test-")
    git(repo, "init", "-q", "-b", "main")
    git(repo, "config", "user.email", "t@example.com"); git(repo, "config", "user.name", "t")
    open(os.path.join(repo, "a.txt"), "w").write("one\n")
    git(repo, "add", "-A"); git(repo, "commit", "-q", "-m", "init")
    return repo


def run(repo, fake_cmd, *extra, backend="fake"):
    prompt = os.path.join(repo, "..", os.path.basename(repo) + ".prompt")
    open(prompt, "w").write("Do the task.\n")
    env = {**os.environ, "EXTERNAL_IMPLEMENTER_TEST": "1", "EXTERNAL_IMPLEMENTER_FAKE_CMD": fake_cmd}
    p = subprocess.run([SCRIPT, backend, repo, prompt, *extra], capture_output=True, text=True, env=env)
    return p.returncode, (json.loads(p.stdout) if p.stdout.strip().startswith("{") else {"raw": p.stdout + p.stderr})


class Fake(unittest.TestCase):
    def test_success_verifies_and_commits(self):
        repo = make_repo(); msg = os.path.join(repo, "..", "msg.txt"); open(msg, "w").write("feat: add b\n\nCo-Authored-By: X <x@y>\n")
        code, r = run(repo, "echo 'a new file with enough text in it' > b.txt", "--verify", "test -f b.txt", "--commit-msg-file", msg)
        self.assertEqual((code, r["status"]), (0, "DONE"), r)
        self.assertEqual(r["commit"], git(repo, "rev-parse", "HEAD").strip())
        self.assertEqual(git(repo, "status", "--porcelain"), "")
        self.assertIn("Co-Authored-By", git(repo, "log", "-1", "--format=%B"))

    def test_leaves_work_uncommitted_without_a_message(self):
        repo = make_repo()
        code, r = run(repo, "echo change >> a.txt")
        self.assertEqual((code, r["status"], r["commit"]), (0, "DONE", None), r)
        self.assertIn("a.txt", git(repo, "status", "--porcelain"))

    def test_failed_verify_reports_and_does_not_commit(self):
        repo = make_repo(); msg = os.path.join(repo, "..", "msg2.txt"); open(msg, "w").write("x\n")
        code, r = run(repo, "echo change >> a.txt", "--verify", "echo boom; exit 3", "--commit-msg-file", msg, "--retries", "0")
        self.assertEqual((code, r["status"]), (1, "VERIFY_FAILED"), r)
        self.assertEqual(r["verify"][0]["exit"], 3); self.assertIn("boom", r["verify"][0]["tail"])
        self.assertEqual(git(repo, "log", "--oneline").count("\n"), 1)

    def test_retry_appends_the_failure_and_can_succeed(self):
        repo = make_repo()
        fake = 'if grep -q "previous attempt failed" "$0" 2>/dev/null; then :; fi; test -f ok.flag && echo fixed >> a.txt || { touch ok.flag; echo broken >> a.txt; }'
        code, r = run(repo, fake, "--verify", "grep -q fixed a.txt", "--retries", "1")
        self.assertEqual((code, r["status"]), (0, "DONE"), r)

    def test_no_changes(self):
        code, r = run(make_repo(), "true")
        self.assertEqual((code, r["status"]), (1, "NO_CHANGES"), r)

    def test_quota_text_blocks(self):
        code, r = run(make_repo(), "echo 'You have reached your usage limit. Try again in 3 hours.'; exit 1")
        self.assertEqual((code, r["status"]), (1, "BLOCKED_QUOTA"), r)

    def test_quota_words_in_a_successful_run_are_not_a_block(self):
        code, r = run(make_repo(), "echo 'adding a rate limit to the route'; echo change >> a.txt")
        self.assertEqual((code, r["status"]), (0, "DONE"), r)

    def test_dirty_repo_is_refused(self):
        repo = make_repo(); open(os.path.join(repo, "a.txt"), "a").write("dirty\n")
        code, r = run(repo, "true")
        self.assertEqual((code, r["status"]), (1, "ERROR"), r); self.assertIn("clean", r["error"])

    def test_timeout(self):
        code, r = run(make_repo(), "sleep 30", "--timeout", "1")
        self.assertEqual((code, r["status"]), (1, "TIMEOUT"), r)

    def test_nonce_is_unique_and_in_the_prompt(self):
        repo = make_repo(); code, r = run(repo, "echo change >> a.txt")
        prompt = open(os.path.join(r["out_dir"], "prompt.txt")).read()
        self.assertRegex(prompt, r"Run id: EXTIMPL-[0-9a-f]{12}"); self.assertIn("Do not run git commit", prompt)


@unittest.skipUnless(os.environ.get("EXTERNAL_IMPLEMENTER_LIVE") == "1", "set EXTERNAL_IMPLEMENTER_LIVE=1 for the real Codex smoke test")
class Live(unittest.TestCase):
    def test_codex_end_to_end(self):
        repo = make_repo(); prompt = os.path.join(repo, "..", "live.prompt"); msg = os.path.join(repo, "..", "live.msg")
        open(prompt, "w").write("Create a file hello.txt in the repository root containing exactly the line: hello from the external implementer\n")
        open(msg, "w").write("test: hello\n\nCo-Authored-By: GPT-6.1-Sol <noreply@openai.com>\n")
        p = subprocess.run([SCRIPT, "codex", repo, prompt, "--verify", "grep -q 'hello from the external implementer' hello.txt", "--commit-msg-file", msg],
                           capture_output=True, text=True)
        r = json.loads(p.stdout)
        self.assertIn(r["status"], ("DONE", "DONE_WITH_CONCERNS"), r)
        self.assertIn("gpt-6.1-sol", r["models"]); self.assertTrue(r["cwd_ok"]); self.assertTrue(r["session"])
        self.assertEqual(r["commit"], git(repo, "rev-parse", "HEAD").strip())
        self.assertEqual(r["strays"], [])


if __name__ == "__main__":
    unittest.main(verbosity=2)
