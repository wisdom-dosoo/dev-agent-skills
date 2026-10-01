# Demos (60 seconds each)

Three runnable "catch" moments. Run any one; each exits non-zero by design (a caught problem is the point — CI equivalents live in `evals/check-fixtures.sh`).

| Demo | Command | Shows |
|---|---|---|
| 1. Leaked secrets | `bash demos/demo-secrets.sh` | Live key + browser-bundled secret + private key file, each with fix |
| 2. Unshippable landing page | `bash demos/demo-site.sh` | Broken links FAIL + every missing SEO tag named |
| 3. Untested project | `bash demos/demo-tests.sh` | Zero-test FAIL, then the tested twin passing |

Full transcripts: `demos/transcripts/*.txt` (generated from these scripts; machine paths trimmed).

## Recording GIFs for socials

```bash
asciinema rec -c "bash demos/demo-secrets.sh" demo-secrets.cast
agg demo-secrets.cast demo-secrets.gif   # needs asciinema + agg
```

Keep it to one take under 60 seconds: run the script, pause on the FAIL lines, end on the takeaway. Post the GIF with the transcript link for accessibility (GIFs alone exclude screen-reader users).
