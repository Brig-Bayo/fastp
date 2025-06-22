# Long Reads Quality Control and Trimming Pipeline

![Pipeline Status](https://img.shields.io/badge/status-stable-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)


## Overview

This pipeline provides comprehensive quality control and trimming for long-read sequencing data using [fastp](https://github.com/OpenGene/fastp). It's specifically optimized for long reads from technologies like Oxford Nanopore and PacBio, offering automated processing with detailed reporting and logging.

## Features

- ✅ **Automated Quality Control**: Comprehensive QC analysis with HTML reports
- ✅ **Intelligent Trimming**: Length-based filtering and quality trimming
- ✅ **Adapter Removal**: Support for custom adapter sequences
- ✅ **Poly-G/Poly-X Trimming**: Remove homopolymer artifacts
- ✅ **Low Complexity Filtering**: Remove low-complexity sequences
- ✅ **Batch Processing**: Process multiple FASTQ files simultaneously
- ✅ **Detailed Logging**: Comprehensive logs for each processing step
- ✅ **Summary Reports**: Consolidated processing statistics
- ✅ **Flexible Configuration**: Customizable parameters for different use cases

## Requirements

### System Requirements
- Linux/Unix operating system
- Bash shell (version 4.0 or higher)
- 4GB RAM minimum (8GB+ recommended for large datasets)
- Sufficient disk space (3x input file size recommended)

### Software Dependencies
- [fastp](https://github.com/OpenGene/fastp) (version 0.20.0 or higher)
- Standard Unix tools: `find`, `grep`, `wget`, `curl`

## Installation

### Quick Start
```bash
# Clone or download the scripts
git clone <repository-url>
cd long-reads-qc-pipeline

# Make scripts executable
chmod +x *.sh

# Install dependencies
./install_dependencies.sh

# Run the pipeline
./long_reads_qc.sh -i /path/to/input -o /path/to/output
```

### Manual Installation

1. **Install fastp**:
   ```bash
   # Using conda (recommended)
   conda install -c bioconda fastp
   
   # Or using binary download
   wget https://github.com/OpenGene/fastp/releases/download/v0.23.2/fastp
   chmod +x fastp
   sudo mv fastp /usr/local/bin/
   ```

2. **Download pipeline scripts**:
   ```bash
   wget https://raw.githubusercontent.com/your-repo/long_reads_qc.sh
   wget https://raw.githubusercontent.com/your-repo/install_dependencies.sh
   chmod +x *.sh
   ```

## Usage

### Basic Usage
```bash
./long_reads_qc.sh -i input_directory -o output_directory
```

### Advanced Usage
```bash
./long_reads_qc.sh \
  -i /data/raw_reads \
  -o /data/processed_reads \
  -t 8 \
  -l 500 \
  -q 10 \
  -a adapters.fasta \
  --no-trim-poly-g
```

### Command Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-i, --input-dir` | Input directory containing FASTQ files | **Required** |
| `-o, --output-dir` | Output directory for processed files | **Required** |
| `-t, --threads` | Number of processing threads | 4 |
| `-l, --min-length` | Minimum read length after trimming | 1000 |
| `-q, --quality-threshold` | Quality score threshold | 7 |
| `-a, --adapter-fasta` | FASTA file with adapter sequences | None |
| `-g, --no-trim-poly-g` | Disable poly-G trimming | False |
| `-x, --no-trim-poly-x` | Disable poly-X trimming | False |
| `-c, --complexity` | Low complexity threshold | 30 |
| `-r, --no-report` | Skip HTML report generation | False |
| `-h, --help` | Display help message |  |
| `-v, --version` | Display version information |  |

### Input File Formats
Supported input formats:
- `.fastq` - Uncompressed FASTQ
- `.fq` - Uncompressed FASTQ
- `.fastq.gz` - Gzip-compressed FASTQ
- `.fq.gz` - Gzip-compressed FASTQ

## Output Structure

The pipeline creates the following output structure:

```
output_directory/
├── trimmed/                    # Processed FASTQ files
│   ├── sample1_trimmed.fastq.gz
│   ├── sample2_trimmed.fastq.gz
│   └── ...
├── reports/                    # HTML and JSON reports
│   ├── sample1_fastp_report.html
│   ├── sample1_fastp_report.json
│   ├── sample2_fastp_report.html
│   ├── sample2_fastp_report.json
│   └── ...
├── logs/                       # Processing logs
│   ├── sample1_fastp.log
│   ├── sample2_fastp.log
│   └── ...
└── processing_summary.txt      # Summary report
```

### Output Files Description

- **trimmed/**: Contains quality-controlled and trimmed FASTQ files
- **reports/**: HTML reports with detailed QC metrics and JSON files with structured data
- **logs/**: Individual processing logs for each sample
- **processing_summary.txt**: Overall pipeline summary with parameters and statistics

## Configuration Examples

### Example 1: Basic Long Read Processing
```bash
./long_reads_qc.sh -i ./nanopore_reads -o ./processed_nanopore
```

### Example 2: High-Quality Filtering
```bash
./long_reads_qc.sh \
  -i ./raw_reads \
  -o ./high_quality_reads \
  -l 2000 \
  -q 12 \
  -c 50
```

### Example 3: Adapter Trimming with Custom Adapters
```bash
./long_reads_qc.sh \
  -i ./raw_reads \
  -o ./adapter_trimmed \
  -a custom_adapters.fasta \
  -t 16
```

### Example 4: Minimal Processing
```bash
./long_reads_qc.sh \
  -i ./raw_reads \
  -o ./minimal_processed \
  -l 100 \
  --no-trim-poly-g \
  --no-trim-poly-x \
  --no-report
```

## Performance Considerations

### Memory Usage
- **Typical usage**: 2-4GB RAM per thread
- **Large files (>10GB)**: 8-16GB RAM recommended
- **Memory scaling**: Approximately linear with thread count

### Processing Speed
- **Typical throughput**: 50-200 MB/min per thread
- **Bottlenecks**: I/O operations, compression level
- **Optimization**: Use SSD storage, adjust thread count based on CPU cores

### Thread Recommendations
- **Small datasets (<1GB)**: 2-4 threads
- **Medium datasets (1-10GB)**: 4-8 threads
- **Large datasets (>10GB)**: 8-16 threads
- **Rule of thumb**: Start with number of CPU cores, adjust based on performance

## Troubleshooting

### Common Issues

1. **"fastp is not installed"**
   ```bash
   # Solution: Install fastp
   ./install_dependencies.sh
   # Or manually install
   conda install -c bioconda fastp
   ```

2. **"No FASTQ files found"**
   ```bash
   # Check input directory
   ls -la /path/to/input/
   # Ensure files have correct extensions (.fastq, .fq, .fastq.gz, .fq.gz)
   ```

3. **"Permission denied"**
   ```bash
   # Make scripts executable
   chmod +x long_reads_qc.sh
   # Check output directory permissions
   ls -ld /path/to/output/
   ```

4. **"Out of memory"**
   ```bash
   # Reduce thread count
   ./long_reads_qc.sh -i input -o output -t 2
   # Process files individually
   ```

### Log File Analysis
Check individual log files in the `logs/` directory for detailed error messages:
```bash
# View processing log
cat output_directory/logs/sample_name_fastp.log

# Check for errors
grep -i error output_directory/logs/*.log
```

## Quality Control Metrics

The pipeline generates comprehensive QC metrics including:

### Read Statistics
- Total number of reads (before/after)
- Total bases (before/after)
- Read length distribution
- GC content

### Quality Metrics
- Quality score distribution
- Per-base quality scores
- Quality score heatmap

### Filtering Statistics
- Reads filtered by length
- Reads filtered by quality
- Reads filtered by complexity
- Adapter trimming statistics

### Performance Metrics
- Processing time
- Memory usage
- Throughput (reads/second)

## Best Practices

### Data Preparation
1. **Organize input files**: Keep all FASTQ files in a single directory
2. **File naming**: Use consistent, descriptive names
3. **Check file integrity**: Verify files are not corrupted before processing
4. **Backup important data**: Always keep copies of raw data

### Parameter Selection
1. **Minimum length**: Set based on your analysis requirements
   - Assembly: 1000-5000 bp
   - Mapping: 500-2000 bp
   - Metagenomics: 100-1000 bp

2. **Quality threshold**: Adjust based on sequencing technology
   - Nanopore: 7-10
   - PacBio: 10-15
   - Illumina: 20-30

3. **Thread count**: Match to your system resources
   - Start with CPU core count
   - Monitor memory usage
   - Adjust based on performance

### Workflow Integration
1. **Upstream**: Raw sequencing data
2. **Downstream**: Assembly, mapping, analysis
3. **Quality check**: Always review QC reports before downstream analysis
4. **Batch processing**: Process related samples together

## Version History

### v1.0.0 (Current)
- Initial release
- Basic QC and trimming functionality
- HTML report generation
- Batch processing support
- Comprehensive logging

### Planned Features
- [ ] Multi-sample comparison reports
- [ ] Integration with popular assemblers
- [ ] Docker containerization
- [ ] Nextflow/Snakemake workflow support
- [ ] Real-time processing monitoring

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Reporting Issues
Please report bugs and feature requests through the [GitHub Issues](https://github.com/your-repo/issues) page.

## Citation

If you use this pipeline in your research, please cite:

```bibtex
@software{boamah2024longreadsqc,
  title={Long Reads Quality Control and Trimming Pipeline},
  author={Boamah, Bright},
  year={2024},
  url={https://github.com/your-repo/long-reads-qc-pipeline},
  version={1.0.0}
}
```

Also please cite fastp:
```bibtex
@article{chen2018fastp,
  title={fastp: an ultra-fast all-in-one FASTQ preprocessor},
  author={Chen, Shifu and Zhou, Yanqing and Chen, Yaru and Gu, Jia},
  journal={Bioinformatics},
  volume={34},
  number={17},
  pages={i884--i890},
  year={2018},
  publisher={Oxford University Press}
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contacts

**Author:** Bright Boamah  
**Email:** [brigbayo@icloud.com]  
**GitHub:** [https://github.com/Brig-Bayo]  

## Acknowledgments

- [fastp](https://github.com/OpenGene/fastp) developers for the excellent preprocessing tool
- The bioinformatics community for feedback and suggestions
- Contributors and users who help improve this pipeline

---

*This pipeline is designed to be robust, user-friendly, and suitable for production use. For questions, suggestions, or issues, please don't hesitate to reach out.*
