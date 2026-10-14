#!/bin/bash
# ============================================================
# Novel loci: formal LD-based clumping of the SNPs that survived
# the exact-match / 50kb pre-filter, against the pooled set of
# previously-reported imaging-genetics SNPs.
# ============================================================
# Input: one file per chromosome in clump_input/, each with columns
#   SNP   P
# containing BOTH the ~4,614 of our SNPs that need a formal check
# AND the (deduplicated) external SNPs from the 12 comparison papers,
# all given the SAME dummy p-value (1e-8) -- see build_clump_input.py
# for why: PLINK --clump requires a P column to rank clump membership,
# but here we only care about CLUSTER MEMBERSHIP (is one of our SNPs
# in the same LD clump as an external SNP), not which SNP "wins" as
# the index SNP, so a uniform dummy value removes any arbitrary bias
# in index-SNP selection.
#
# EDIT THESE before running:
BFILE_PREFIX="/path/to/ukb_genotypes/ukb_chr"   # expects ukb_chr{CHR}.bed/.bim/.fam
INPUT_DIR="clump_input"
OUT_DIR="clump_output"
CLUMP_KB=250     # PLINK default; widen to 500-1000 to be more conservative
CLUMP_R2=0.1     # PLINK default LD threshold for same-clump membership
# ============================================================

mkdir -p "$OUT_DIR"

for CHR in $(seq 1 22) 23; do
  INFILE="${INPUT_DIR}/chr${CHR}_clump_input.txt"
  if [ ! -f "$INFILE" ]; then
    echo "Skipping chr${CHR}: no input file found"
    continue
  fi

  plink \
    --bfile "${BFILE_PREFIX}${CHR}" \
    --clump "$INFILE" \
    --clump-snp-field SNP \
    --clump-field P \
    --clump-p1 1 \
    --clump-p2 1 \
    --clump-kb ${CLUMP_KB} \
    --clump-r2 ${CLUMP_R2} \
    --out "${OUT_DIR}/chr${CHR}_clumped"

  echo "chr${CHR} done"
done

echo ""
echo "All chromosomes done. Output .clumped files are in ${OUT_DIR}/"
echo "Send the whole ${OUT_DIR}/ folder (or just the *.clumped files) back"
echo "and the novel/known classification can be finished from there --"
echo "each clump gets cross-referenced against which SNPs in it came from"
echo "'ours' vs the external comparison papers."
