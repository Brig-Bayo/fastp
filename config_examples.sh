#!/bin/bash

# Configuration Examples for Long Reads QC Pipeline
# Author: Bright Boamah
# Date: $(date +%Y-%m-%d)
# Description: Example configurations for different sequencing platforms and use cases

# This file contains example configurations for various scenarios.
# Copy and modify these examples to suit your specific needs.

set -euo pipefail

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Long Reads QC Pipeline - Configuration Examples${NC}"
echo -e "${BLUE}Author: Bright Boamah${NC}"
echo ""

# Function to display example
show_example() {
    local title="$1"
    local description="$2"
    local command="$3"
    
    echo -e "${GREEN}=== $title ===${NC}"
    echo -e "${YELLOW}Description:${NC} $description"
    echo -e "${YELLOW}Command:${NC}"
    echo "$command"
    echo ""
}

# Example 1: Oxford Nanopore MinION/GridION
show_example "Oxford Nanopore MinION/GridION" \
    "Optimized for Nanopore long reads with typical quality scores" \
    "./long_reads_qc.sh \\
  -i ./nanopore_reads \\
  -o ./processed_nanopore \\
  -t 8 \\
  -l 1000 \\
  -q 7 \\
  -c 30"

# Example 2: Oxford Nanopore PromethION
show_example "Oxford Nanopore PromethION" \
    "High-throughput Nanopore with more aggressive filtering" \
    "./long_reads_qc.sh \\
  -i ./promethion_reads \\
  -o ./processed_promethion \\
  -t 16 \\
  -l 2000 \\
  -q 8 \\
  -c 35"

# Example 3: PacBio Sequel/HiFi
show_example "PacBio Sequel/HiFi" \
    "High-quality PacBio reads with stringent filtering" \
    "./long_reads_qc.sh \\
  -i ./pacbio_reads \\
  -o ./processed_pacbio \\
  -t 12 \\
  -l 500 \\
  -q 12 \\
  -c 40 \\
  --no-trim-poly-g"

# Example 4: Metagenomics
show_example "Metagenomics Analysis" \
    "Relaxed filtering for diverse microbial communities" \
    "./long_reads_qc.sh \\
  -i ./metagenomic_reads \\
  -o ./processed_metagenomics \\
  -t 8 \\
  -l 500 \\
  -q 6 \\
  -c 25"

# Example 5: Transcriptomics
show_example "Transcriptomics (RNA-seq)" \
    "Optimized for RNA sequencing with poly-A trimming" \
    "./long_reads_qc.sh \\
  -i ./rna_reads \\
  -o ./processed_rna \\
  -t 6 \\
  -l 200 \\
  -q 8 \\
  -c 30"

# Example 6: Genome Assembly
show_example "Genome Assembly" \
    "High-quality long reads for de novo assembly" \
    "./long_reads_qc.sh \\
  -i ./assembly_reads \\
  -o ./processed_assembly \\
  -t 16 \\
  -l 5000 \\
  -q 10 \\
  -c 45"

# Example 7: Amplicon Sequencing
show_example "Amplicon Sequencing" \
    "Targeted amplicon sequencing with adapter removal" \
    "./long_reads_qc.sh \\
  -i ./amplicon_reads \\
  -o ./processed_amplicons \\
  -t 4 \\
  -l 800 \\
  -q 12 \\
  -a amplicon_adapters.fasta \\
  -c 35"

# Example 8: Quick Quality Check
show_example "Quick Quality Check" \
    "Fast processing for initial data assessment" \
    "./long_reads_qc.sh \\
  -i ./raw_reads \\
  -o ./quick_qc \\
  -t 4 \\
  -l 100 \\
  -q 5 \\
  -c 20 \\
  --no-trim-poly-x"

# Example 9: High-Stringency Filtering
show_example "High-Stringency Filtering" \
    "Maximum quality filtering for critical applications" \
    "./long_reads_qc.sh \\
  -i ./raw_reads \\
  -o ./high_stringency \\
  -t 8 \\
  -l 10000 \\
  -q 15 \\
  -c 50"

# Example 10: Minimal Processing
show_example "Minimal Processing" \
    "Basic length filtering only" \
    "./long_reads_qc.sh \\
  -i ./raw_reads \\
  -o ./minimal_processed \\
  -t 2 \\
  -l 200 \\
  -q 3 \\
  -c 10 \\
  --no-trim-poly-g \\
  --no-trim-poly-x \\
  --no-report"

# Platform-specific adapter sequences
echo -e "${GREEN}=== Common Adapter Sequences ===${NC}"
echo -e "${YELLOW}Note:${NC} Save these sequences in FASTA format for adapter trimming"
echo ""

echo -e "${BLUE}Oxford Nanopore Adapters:${NC}"
cat << 'EOF'
>ONT_adapter1
AATGTACTTCGTTCAGTTACGTATTGCT
>ONT_adapter2
GCAATACGTAACTGAACGAAGT
>ONT_barcoding_adapter
AAGAAAGTTGTCGGTGTCTTTGTG
EOF
echo ""

echo -e "${BLUE}PacBio Adapters:${NC}"
cat << 'EOF'
>PacBio_adapter1
ATCTCTCTCTTTTCCTCCTCCTCCGTTGTTGTTGTTGAGAGAGAT
>PacBio_adapter2
ATCTCTCTCAACAACAACGGAGGAGGAGGAAAAGAGAGAGAT
EOF
echo ""

echo -e "${BLUE}Generic PCR Primers:${NC}"
cat << 'EOF'
>PCR_primer_F
GTTTCCCAGTCACGATA
>PCR_primer_R
TATCGTCACGAGTTCCC
EOF
echo ""

# Performance tuning recommendations
echo -e "${GREEN}=== Performance Tuning Recommendations ===${NC}"
echo ""

echo -e "${YELLOW}Thread Count Guidelines:${NC}"
echo "- Small files (<1GB): 2-4 threads"
echo "- Medium files (1-10GB): 4-8 threads" 
echo "- Large files (>10GB): 8-16 threads"
echo "- Never exceed: Number of CPU cores"
echo ""

echo -e "${YELLOW}Memory Considerations:${NC}"
echo "- Typical usage: 2-4GB RAM per thread"
echo "- Large files: 8-16GB RAM total recommended"
echo "- Monitor with: htop or top during processing"
echo ""

echo -e "${YELLOW}Storage Optimization:${NC}"
echo "- Use SSD for input/output if possible"
echo "- Ensure 3x input file size free space"
echo "- Consider temporary directory on fastest storage"
echo ""

# Quality thresholds by platform
echo -e "${GREEN}=== Quality Threshold Guidelines ===${NC}"
echo ""

echo -e "${YELLOW}Oxford Nanopore:${NC}"
echo "- MinION/GridION: Q7-Q10"
echo "- PromethION: Q8-Q12"
echo "- High accuracy basecalling: Q10-Q15"
echo ""

echo -e "${YELLOW}PacBio:${NC}"
echo "- Sequel I: Q10-Q15"
echo "- Sequel II: Q12-Q18"
echo "- HiFi reads: Q15-Q20"
echo ""

echo -e "${YELLOW}Length Filtering Guidelines:${NC}"
echo "- Genome assembly: 1000-5000 bp minimum"
echo "- Transcriptomics: 200-1000 bp minimum"
echo "- Metagenomics: 500-2000 bp minimum"
echo "- Amplicon sequencing: Based on expected amplicon size"
echo ""

# Troubleshooting common issues
echo -e "${GREEN}=== Common Configuration Issues ===${NC}"
echo ""

echo -e "${YELLOW}Issue: Out of memory${NC}"
echo "Solution: Reduce thread count (-t) or process fewer files at once"
echo ""

echo -e "${YELLOW}Issue: Too slow processing${NC}"
echo "Solution: Increase threads (-t) but monitor memory usage"
echo ""

echo -e "${YELLOW}Issue: Too many reads filtered out${NC}"
echo "Solution: Lower quality threshold (-q) or minimum length (-l)"
echo ""

echo -e "${YELLOW}Issue: Not enough reads filtered${NC}"
echo "Solution: Increase quality threshold (-q) or complexity threshold (-c)"
echo ""

echo -e "${GREEN}=== Configuration Testing ===${NC}"
echo ""
echo "To test your configuration with a small subset:"
echo "1. Create a test directory with a few small FASTQ files"
echo "2. Run your configuration on the test data"
echo "3. Check the processing_summary.txt for filtering statistics"
echo "4. Adjust parameters based on results"
echo ""

echo -e "${BLUE}For more detailed information, see the README.md file${NC}"
