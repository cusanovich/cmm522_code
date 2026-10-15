# CMM 522 — Crash Course in Bioinformatics for Biologists

Example files and scripts used by the course assignments, plus the notes
needed to run the course again next year.

Students: the assignments will tell you when to download something from here —
usually with `wget` and a `raw.githubusercontent.com` link. You do not need to
clone the repository, and nothing below this line is aimed at you.

---

Eight in-class assignments, eight homeworks, nine lectures, nine sessions.

**Status:** taught Fall 2026, ran smoothly. The content is stable. What is not
stable is the cluster environment underneath it, and that is what this document
is about.

---

## Run the pre-flight check first

`preflight_cmm522.sh` verifies everything the course assumes about the
environment. Run it in August, as a batch job:

```bash
cd ~/ccbb_projects/cmm522_code
sbatch preflight_cmm522.sbatch
squeue --me
```

The result lands in `preflight_<jobid>.log`.

**Budget 10 to 30 minutes.** Nearly all of it is the R package step: tidyverse
pulls in around ninety dependencies, and whether that takes three minutes or
thirty depends on whether the site has a binary package repository configured.
The script prints which repository it used and times each install, so the log
tells you which case you are in. That is worth knowing on its own — if it built
from source, your students sat through the same wait during InClass7.

Batch rather than interactive for that reason. It will run interactively if you
prefer (`bash preflight_cmm522.sh`, from a compute node — modules do not exist
on login nodes), but it is a long time to hold a session open.

It checks R versions, python modules and which is default, every R package the
assignments install, the command line tools, and all 39 links. R packages go
into a temporary library that is deleted afterwards, so it changes nothing.

Everything below is context for interpreting what it tells you.

## What the course depends on

| | |
|---|---|
| **R** | 4.5.2, named explicitly in InClass7, InClass8, HW7, HW8 |
| **R packages** | swirl, tidyverse, tidyr, remotes, rlang, vctrs, glue |
| **From GitHub** | generativeart (`cutterkom/generativeart`), InClass8 |
| **Modules** | `python/3.11/3.11.4`, `python/3.14/3.14.2` |
| **Tools** | wget, curl, awk, sed, grep, git |
| **Links** | 39 — 5 from `cusanovich/cmm522_code`, 34 external |

## Known fragilities

Ordered by how likely each is to bite.

**The python default lesson is the subtlest thing in the course.** InClass2
Steps 10–12 teach students to name module versions explicitly, and the example
is that `python/3.11/3.11.4` is the default even though `3.14` exists — "usually
the most current version will be the default, but with Python that's not true
right now." If HPC promotes 3.14 to default, that passage becomes false. No
error will fire. The text just quietly stops being true, and the lesson lands
backwards. The pre-flight check tests this specifically.

**The R version is hardcoded in four documents.** When 4.5.2 disappears from
the module list, InClass7, InClass8, HW7 and HW8 all need the same edit. Worth
doing as one find-and-replace rather than discovering it mid-session.

**generativeart installs from GitHub.** Unauthenticated GitHub API requests are
rate-limited to 60 per hour *per IP*, and the whole cluster shares one. A class
of twenty hitting it in the same ten minutes will exhaust that. If InClass8
fails for everyone at once, this is why, and the fix is a personal access
token — which CMM 523 teaches, so there is prior art.

**Thirty-four external links.** These are the most brittle part of the course
and the least likely to announce failure. Links rot, sites reorganize, tutorials
move behind registration. The pre-flight check tests reachability but cannot
tell you whether the page still says what you sent students there to read.

**Modules only exist on compute nodes.** Every year someone runs `module load`
on a login node and gets a confusing error. Worth saying out loud in session 1.

**A stale `~/.Renviron` shadows the R library path.** If a student has one from
a previous course it can override the library and produce `undefined symbol`
errors that look like a broken R install. Moving the file aside fixes it.

## Before the next run

1. **Run the pre-flight check.** Work through whatever it flags.
2. **If R moved**, update the version in InClass7, InClass8, HW7, HW8.
3. **If the python default moved**, rewrite InClass2 Steps 10–12 — the example
   depends on the specific versions and on which one is default.
4. **Open the flagged links by hand.** Reachable is not the same as correct.
5. **Check the broken-scripts folder** for the debugging exercise, and confirm
   there are enough for the roster. The folder is not student-readable; keep
   it that way.
6. **Add students to `cusanovichlab`** once the roster is final.
7. **Update the lecture decks** — dates on nine title slides.

## Ideas for next year

**Host our own copies of the critical tutorials.** The external links are the
weakest dependency and the one with the least recourse: when a page disappears
mid-semester there is nothing to do about it. The CMM 523 approach — rewriting
borrowed tutorials as our own rendered markdown on GitHub, with a pointer to
the original kept so students still learn to read other people's docs — applies
here directly. It does not have to happen all at once; the handful that
assignments depend on most would cover most of the risk.

**Keep `cmm523_base.sif` as an R fallback.** Not a redesign — 522 is partly
*about* learning to work with the cluster's own R, and containerizing that would
remove the lesson. But if the HPC's R breaks two days before InClass7, a working
R already exists at
`/groups/darrenc/cmm_523/containers/cmm523_base.sif` and the session can go
ahead.
