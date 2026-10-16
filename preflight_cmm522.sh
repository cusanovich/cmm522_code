#!/bin/bash
# ============================================================================
# CMM 522 -- pre-flight check
#
# Run this in August, before the semester, on a COMPUTE NODE:
#
#     interactive -a cusanovichlab -n 4 -t 02:00:00
#     bash preflight_cmm522.sh 2>&1 | tee preflight_$(date +%Y).log
#
# Budget 10-30 minutes. Most of that is the R package step: tidyverse pulls in
# roughly ninety dependencies, and if the site has no binary repository
# configured they are all built from source. The script prints each package as
# it starts, so you can tell progress from a hang.
#
# Modules are not available on login nodes, so the module checks will report
# nothing useful if you run this on wentletrap.
#
# Nothing here installs into your real library or changes any course file.
# R packages are installed into a temporary directory that is deleted at the
# end. The script is read-only with respect to everything you care about.
#
# What it is for: the content of CMM 522 is stable, but the environment under
# it is not. R versions come and go, module defaults change, and linked
# tutorials rot. Each of those breaks an assignment silently, usually in front
# of students. This fails loudly in August instead.
# ============================================================================

set -u
FAIL=0
note()  { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
pass()  { printf '  ok    %s\n' "$1"; }
warn()  { printf '  WARN  %s\n' "$1"; FAIL=1; }
bad()   { printf '  FAIL  %s\n' "$1"; FAIL=1; }

# --- what the assignments currently assume -------------------------------
# Update these when you deliberately move the course to a new version.
EXPECT_R="4.5.2"
EXPECT_PY_DEFAULT="3.11"      # InClass2 teaches that the default is NOT newest
EXPECT_PY_ALT="3.14"

note "Where am I"
hostname
if ! command -v module >/dev/null 2>&1; then
  bad "'module' not found -- you are probably on a login node. Start an interactive session."
  exit 1
fi
pass "module command available"

# --- R --------------------------------------------------------------------
note "R versions"
R_AVAIL=$(module avail r 2>&1 | grep -oE '\br/[0-9]+\.[0-9]+\.[0-9]+' | sort -Vu)
if [ -z "$R_AVAIL" ]; then
  R_AVAIL=$(module avail R 2>&1 | grep -oE '\bR/[0-9]+\.[0-9]+\.[0-9]+' | sort -Vu)
fi
if [ -z "$R_AVAIL" ]; then
  bad "no R modules found -- check 'module avail' by hand"
else
  echo "$R_AVAIL" | sed 's/^/        /'
  if echo "$R_AVAIL" | grep -q "$EXPECT_R"; then
    pass "R $EXPECT_R still available (assignments name this version)"
  else
    bad "R $EXPECT_R is GONE. InClass7, InClass8 and HW7/HW8 name it explicitly."
  fi
fi

# --- python ---------------------------------------------------------------
note "Python modules  (InClass2 Steps 10-12 depend on these)"
PY_RAW=$(module avail python 2>&1)
echo "$PY_RAW" | grep -oE 'python/[0-9.]+/[0-9.]+ *(\([^)]*\))?' | sed 's/^/        /' | sort -u
# Ask Lmod directly rather than parsing markers: the flag on a default module
# is (D), but it is (L,D) when the module also happens to be loaded, and
# marker formats vary between Lmod versions.
PY_DEFAULT=$(module --default avail python 2>&1 \
             | grep -oE 'python/[0-9]+\.[0-9]+/' | grep -oE '[0-9]+\.[0-9]+' | head -1)
if [ -z "$PY_DEFAULT" ]; then
  # Fall back to the marker, accepting (D), (L,D) and (D,L).
  PY_DEFAULT=$(echo "$PY_RAW" | grep -oE 'python/[0-9.]+/[0-9.]+ *\([^)]*D[^)]*\)' \
               | grep -oE '[0-9]+\.[0-9]+' | head -1)
fi
if [ -z "$PY_DEFAULT" ]; then
  warn "could not determine the default python -- check 'module avail python' by hand"
else
  if [ "$PY_DEFAULT" = "$EXPECT_PY_DEFAULT" ]; then
    pass "default python is still $EXPECT_PY_DEFAULT"
  else
    warn "default python is now $PY_DEFAULT, not $EXPECT_PY_DEFAULT"
    echo "        InClass2 Step 10 tells students the default is NOT the newest"
    echo "        version, and uses $EXPECT_PY_DEFAULT vs $EXPECT_PY_ALT to make the point."
    echo "        If that is no longer true, the text is wrong and needs rewriting."
  fi
fi

# --- R packages -----------------------------------------------------------
note "R package installs  (temporary library, removed afterwards)"
TMPLIB=$(mktemp -d)
module load "r/${EXPECT_R}" 2>/dev/null || module load "R/${EXPECT_R}" 2>/dev/null || true

# NOTE: deliberately NOT --vanilla. --vanilla implies --no-site-file, which
# skips Rprofile.site -- and that is where a site-configured binary package
# repository lives. Skipping it forces every package to build from source,
# which is both far slower and not what a student actually experiences.
Rscript - "$TMPLIB" <<'RS'
args <- commandArgs(trailingOnly = TRUE)
lib  <- args[1]
.libPaths(c(lib, .libPaths()))
options(Ncpus = 4)

# Only set a repository if the site has not already configured one.
r <- getOption("repos")
if (is.null(r[["CRAN"]]) || is.na(r[["CRAN"]]) || r[["CRAN"]] == "@CRAN@") {
  r[["CRAN"]] <- "https://cloud.r-project.org"
  options(repos = r)
}

cat("        R", as.character(getRversion()), "\n")
cat("        repo:", getOption("repos")[["CRAN"]], "\n")
if (grepl("packagemanager|__linux__", getOption("repos")[["CRAN"]])) {
  cat("        (binary repository -- installs should be quick)\n")
} else {
  cat("        (source repository -- tidyverse will take a while)\n")
}

cran <- c("swirl", "tidyverse", "remotes", "rlang", "vctrs", "glue")
bad <- character(0)
for (p in cran) {
  cat("        installing ", p, " ... ", sep = ""); flush.console()
  t0 <- Sys.time()
  ok <- tryCatch({
    suppressMessages(install.packages(p, lib = lib, quiet = TRUE))
    requireNamespace(p, lib.loc = lib, quietly = TRUE)
  }, error = function(e) FALSE)
  secs <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")))
  cat(if (ok) "ok" else "FAILED", " (", secs, "s)\n", sep = "")
  if (!ok) bad <- c(bad, p)
}

# generativeart comes from GitHub (InClass8). The shared cluster IP hits
# GitHub's unauthenticated rate limit easily, so a failure here may be the
# limit rather than the package.
cat("        installing generativeart (GitHub) ... "); flush.console()
ok <- tryCatch({
  remotes::install_github("cutterkom/generativeart", lib = lib,
                          upgrade = "never", quiet = TRUE)
  requireNamespace("generativeart", lib.loc = lib, quietly = TRUE)
}, error = function(e) { cat("\n        ", conditionMessage(e), "\n"); FALSE })
cat(if (ok) "ok\n" else "FAILED\n", sep = "")
if (!ok) bad <- c(bad, "generativeart")

if (length(bad)) {
  cat("\n        FAILED:", paste(bad, collapse = ", "), "\n")
  quit(status = 1)
}
RS
[ $? -eq 0 ] || FAIL=1
rm -rf "$TMPLIB"

# --- command line tools ---------------------------------------------------
note "Command line tools"
for t in wget curl awk sed grep git; do
  if command -v "$t" >/dev/null 2>&1; then pass "$t"; else bad "$t not found"; fi
done

# --- links ----------------------------------------------------------------
note "Links in the assignments"
echo "  (a redirect is fine; 404 and connection failures are not)"
while IFS= read -r u; do
  [ -z "$u" ] && continue
  code=$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 "$u" 2>/dev/null)
  case "$code" in
    200|30*) pass "$code  $u" ;;
    000)     bad  "dead  $u" ;;
    403|405) pass "$code  $u   (blocks automated checks; open it by hand)" ;;
    *)       bad  "$code  $u" ;;
  esac
done <<'URLS'
https://carpentries-incubator.github.io/hpc-intro/13-scheduler/index.html
https://docs.python.org/3/tutorial/index.html
https://flokoe.github.io/bash-hackers-wiki/howto/redirection_tutorial/
https://github.com/cusanovich/cmm522_code/blob/main/generative.ipynb
https://github.com/cusanovich/cmm522_code/blob/main/generative_clean.ipynb
https://github.com/cusanovich/cmm522_code/raw/refs/heads/main/science.txt
https://github.com/cutterkom/generativeart
https://hpcdocs.hpc.arizona.edu/
https://hpcdocs.hpc.arizona.edu/software/popular_software/R/#create-your-first-library
https://info-ee.surrey.ac.uk/Teaching/Unix/
https://mywiki.wooledge.org/BashPitfalls
https://ood.hpc.arizona.edu/pun/sys/dashboard
https://ood.hpc.arizona.edu/pun/sys/dashboard/
https://ostechnix.com/the-grep-command-tutorial-with-examples-for-beginners/
https://pubmed.ncbi.nlm.nih.gov/29539636/
https://raw.githubusercontent.com/cusanovich/cmm522_code/main/error_test2.sbatch
https://raw.githubusercontent.com/cusanovich/cmm522_code/main/fly_6to8_cells.txt
https://raw.githubusercontent.com/cusanovich/cmm522_code/main/gene_results.txt
https://raw.githubusercontent.com/cusanovich/cmm522_code/main/test_bash.sbatch
https://raw.githubusercontent.com/cusanovich/cmm522_code/main/test_bash.sh
https://regexone.com/
https://slurm.schedmd.com/sinfo.html#SECTION_OUTPUT-FIELD-DESCRIPTIONS
https://swcarpentry.github.io/git-novice/
https://towardsdatascience.com/getting-started-with-generative-art-in-r-3bc50067d34b
https://www.bu.edu/tech/support/research/software-and-programming/software-and-applications/modules/
https://www.digitalocean.com/community/tutorials/an-introduction-to-linux-i-o-redirection
https://www.gnu.org/software/gawk/manual/gawk.html#Getting-Started
https://www.grymoire.com/Unix/Sed.html#uh-0
https://www.guru99.com/file-permissions.html
https://www.guru99.com/must-know-linux-commands.html
https://www.guru99.com/terminal-file-manager.html#3
https://www.learnpython.org/
https://www.networkworld.com/article/3620216/troubleshooting-your-bash-scripts.html
https://www.r-bloggers.com/2020/05/generative-art-let-your-computer-design-you-a-painting/
https://www.shell-tips.com/bash/wildcards-globbing/#gsc.tab=0
https://www.uniprot.org/uniprot/P69905.fasta
https://www.youtube.com/watch?v=49DzPT9HFJM&t=207s
https://www.youtube.com/watch?v=I8ik8pDTgJE
https://www.youtube.com/watch?v=zMKacHGuIHI
URLS

# --- summary --------------------------------------------------------------
note "Summary"
if [ "$FAIL" -eq 0 ]; then
  echo "  Everything the course depends on is present and reachable."
else
  echo "  Something above needs attention before the semester starts."
  echo "  Work through the WARN and FAIL lines in order."
fi
exit "$FAIL"
