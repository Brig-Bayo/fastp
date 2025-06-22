#!/bin/bash

# Long Reads Quality Control and Trimming Pipeline
# Author: Bright Boamah
# Date: $(date +%Y-%m-%d)
# Description: Quality control and trimming of long reads using fastp

set -euo pipefail

# Script version
VERSION="1.0.0"

# Default parameters
INPUT_DIR=""
OUTPUT_DIR=""
THREADS=4
MIN_LENGTH=1000
QUALITY_THRESHOLD=7
ADAPTER_FASTA=""
TRIM_POLY_G=true
TRIM_POLY_X=true
COMPLEXITY_THRESHOLD=30
GENERATE_REPORT=true

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    cat << EOF
Long Reads Quality Control and Trimming Pipeline v${VERSION}
Author: Bright Boamah

Usage: $0 [OPTIONS]

Required Options:
  -i, --input-dir DIR          Input directory containing FASTQ files
  -o, --output-dir DIR         Output directory for processed files

Optional Parameters:
  -t, --threads INT            Number of threads (default: 4)
  -l, --min-length INT         Minimum read length after trimming (default: 1000)
  -q, --quality-threshold INT  Quality score threshold (default: 7)
  -a, --adapter-fasta FILE     FASTA file containing adapter sequences
  -g, --no-trim-poly-g         Disable poly-G trimming
  -x, --no-trim-poly-x         Disable poly-X trimming
  -c, --complexity INT         Low complexity threshold (default: 30)
  -r, --no-report             Skip HTML report generation
  -h, --help                   Display this help message
  -v, --version                Display version information

Examples:
  $0 -i /path/to/input -o /path/to/output
  $0 -i ./raw_reads -o ./processed_reads -t 8 -l 500 -q 10
  $0 -i ./data -o ./results -a adapters.fasta --no-trim-poly-g

EOF
}

# Function to log messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check if required tools are installed
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v fastp &> /dev/null; then
        log_error "fastp is not installed. Please install fastp first."
        echo "Installation instructions:"
        echo "  conda install -c bioconda fastp"
        echo "  or"
        echo "  wget http://opengene.org/fastp/fastp && chmod a+x ./fastp"
        exit 1
    fi
    
    log_success "All dependencies are available"
}

# Function to validate input parameters
validate_parameters() {
    log_info "Validating parameters..."
    
    if [[ -z "$INPUT_DIR" ]]; then
        log_error "Input directory is required"
        usage
        exit 1
    fi
    
    if [[ -z "$OUTPUT_DIR" ]]; then
        log_error "Output directory is required"
        usage
        exit 1
    fi
    
    if [[ ! -d "$INPUT_DIR" ]]; then
        log_error "Input directory does not exist: $INPUT_DIR"
        exit 1
    fi
    
    if [[ ! -w "$(dirname "$OUTPUT_DIR")" ]]; then
        log_error "Cannot write to output directory parent: $(dirname "$OUTPUT_DIR")"
        exit 1
    fi
    
    # Check for FASTQ files in input directory
    if ! find "$INPUT_DIR" -name "*.fastq" -o -name "*.fq" -o -name "*.fastq.gz" -o -name "*.fq.gz" | grep -q .; then
        log_error "No FASTQ files found in input directory: $INPUT_DIR"
        exit 1
    fi
    
    log_success "Parameter validation completed"
}

# Function to create output directory structure
setup_output_directory() {
    log_info "Setting up output directory structure..."
    
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR/trimmed"
    mkdir -p "$OUTPUT_DIR/reports"
    mkdir -p "$OUTPUT_DIR/logs"
    
    log_success "Output directory structure created"
}

# Function to process a single FASTQ file
process_fastq_file() {
    local input_file="$1"
    local basename=$(basename "$input_file")
    local sample_name="${basename%.*}"
    
    # Remove additional extensions (.fastq.gz -> sample_name)
    sample_name="${sample_name%.*}"
    
    local output_file="$OUTPUT_DIR/trimmed/${sample_name}_trimmed.fastq.gz"
    local report_file="$OUTPUT_DIR/reports/${sample_name}_fastp_report.html"
    local json_file="$OUTPUT_DIR/reports/${sample_name}_fastp_report.json"
    local log_file="$OUTPUT_DIR/logs/${sample_name}_fastp.log"
    
    log_info "Processing: $basename"
    
    # Build fastp command
    local fastp_cmd="fastp"
    fastp_cmd+=" -i '$input_file'"
    fastp_cmd+=" -o '$output_file'"
    fastp_cmd+=" --thread $THREADS"
    fastp_cmd+=" --qualified_quality_phred $QUALITY_THRESHOLD"
    fastp_cmd+=" --length_required $MIN_LENGTH"
    fastp_cmd+=" --low_complexity_filter"
    fastp_cmd+=" --complexity_threshold $COMPLEXITY_THRESHOLD"
    
    # Long read specific options
    fastp_cmd+=" --disable_adapter_trimming"
    fastp_cmd+=" --disable_quality_filtering"
    
    # Add adapter trimming if specified
    if [[ -n "$ADAPTER_FASTA" ]]; then
        fastp_cmd+=" --adapter_fasta '$ADAPTER_FASTA'"
        fastp_cmd+=" --enable_adapter_trimming"
    fi
    
    # Poly-G trimming
    if [[ "$TRIM_POLY_G" == true ]]; then
        fastp_cmd+=" --trim_poly_g"
    else
        fastp_cmd+=" --disable_trim_poly_g"
    fi
    
    # Poly-X trimming
    if [[ "$TRIM_POLY_X" == true ]]; then
        fastp_cmd+=" --trim_poly_x"
    fi
    
    # Report generation
    if [[ "$GENERATE_REPORT" == true ]]; then
        fastp_cmd+=" --html '$report_file'"
        fastp_cmd+=" --json '$json_file'"
    fi
    
    # Execute fastp command
    log_info "Running fastp for $sample_name..."
    if eval "$fastp_cmd" > "$log_file" 2>&1; then
        log_success "Successfully processed: $sample_name"
        
        # Display basic statistics
        if [[ -f "$json_file" ]]; then
            local reads_before=$(grep -o '"total_reads":[0-9]*' "$json_file" | head -1 | cut -d':' -f2)
            local reads_after=$(grep -o '"total_reads":[0-9]*' "$json_file" | tail -1 | cut -d':' -f2)
            log_info "  Reads before: $reads_before"
            log_info "  Reads after: $reads_after"
        fi
    else
        log_error "Failed to process: $sample_name"
        log_error "Check log file: $log_file"
        return 1
    fi
}

# Function to generate summary report
generate_summary() {
    log_info "Generating summary report..."
    
    local summary_file="$OUTPUT_DIR/processing_summary.txt"
    
    cat > "$summary_file" << EOF
Long Reads Quality Control and Trimming Summary
Author: Bright Boamah
Date: $(date)
Pipeline Version: $VERSION

Parameters Used:
- Input Directory: $INPUT_DIR
- Output Directory: $OUTPUT_DIR
- Threads: $THREADS
- Minimum Length: $MIN_LENGTH
- Quality Threshold: $QUALITY_THRESHOLD
- Trim Poly-G: $TRIM_POLY_G
- Trim Poly-X: $TRIM_POLY_X
- Complexity Threshold: $COMPLEXITY_THRESHOLD

Files Processed:
EOF
    
    find "$OUTPUT_DIR/trimmed" -name "*.fastq.gz" | while read -r file; do
        echo "- $(basename "$file")" >> "$summary_file"
    done
    
    echo "" >> "$summary_file"
    echo "Output Structure:" >> "$summary_file"
    echo "- trimmed/: Processed FASTQ files" >> "$summary_file"
    echo "- reports/: HTML and JSON reports" >> "$summary_file"
    echo "- logs/: Processing logs" >> "$summary_file"
    
    log_success "Summary report generated: $summary_file"
}

# Main execution function
main() {
    log_info "Starting Long Reads QC Pipeline v${VERSION}"
    log_info "Author: Bright Boamah"
    
    check_dependencies
    validate_parameters
    setup_output_directory
    
    # Find and process all FASTQ files
    local processed_count=0
    local failed_count=0
    
    find "$INPUT_DIR" -name "*.fastq" -o -name "*.fq" -o -name "*.fastq.gz" -o -name "*.fq.gz" | while read -r fastq_file; do
        if process_fastq_file "$fastq_file"; then
            ((processed_count++))
        else
            ((failed_count++))
        fi
    done
    
    generate_summary
    
    log_success "Pipeline completed successfully!"
    log_info "Processed files: $processed_count"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "Failed files: $failed_count"
    fi
    log_info "Results available in: $OUTPUT_DIR"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input-dir)
            INPUT_DIR="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -l|--min-length)
            MIN_LENGTH="$2"
            shift 2
            ;;
        -q|--quality-threshold)
            QUALITY_THRESHOLD="$2"
            shift 2
            ;;
        -a|--adapter-fasta)
            ADAPTER_FASTA="$2"
            shift 2
            ;;
        -g|--no-trim-poly-g)
            TRIM_POLY_G=false
            shift
            ;;
        -x|--no-trim-poly-x)
            TRIM_POLY_X=false
            shift
            ;;
        -c|--complexity)
            COMPLEXITY_THRESHOLD="$2"
            shift 2
            ;;
        -r|--no-report)
            GENERATE_REPORT=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            echo "Long Reads QC Pipeline v${VERSION}"
            echo "Author: Bright Boamah"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Run main function
main
