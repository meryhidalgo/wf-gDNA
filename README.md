# wf-gDNA

`wf-gDNA` is a Nextflow DSL2 workflow for processing Oxford Nanopore gDNA data. The current entrypoint, [main.nf](main.nf), reads existing FASTQ files, performs QC, aligns reads to a reference genome, calls variants with Clair3, and phases/haplotags the reads with WhatsHap.

## Workflow Summary

The pipeline runs these main steps:

1. Merge input FASTQ files with `merge_fastqs`.
2. Run `FastQC` on the merged reads.
3. Aggregate QC outputs with `MultiQC`.
4. Align reads to the reference genome with `minimap2`.
5. Sort and index the alignments with `samtools`.
6. Call variants with `Clair3` using the supplied BED regions.
7. Phase variants and haplotag reads with `WhatsHap`.
8. Sort and index the haplotagged BAM file.

## Inputs

The workflow expects these key parameters:

- `fastq_folder`: folder containing `*.fastq.gz` files.
- `genome_fasta`: reference genome FASTA file.
- `bedfile`: BED file with regions to use for variant calling.
- `sample_name`: sample name used in output file names.
- `output_folder`: directory where results are written.

Optional/default parameters used by the workflow configuration:

- `model_name`: Clair3 model name, default `r1041_e82_400bps_sup_v500`.
- `help`: prints the usage message when set to `true`.

Example parameter file: [input_params.yaml](input_params.yaml).

## Run

From the workflow directory:

```bash
nextflow run main.nf -params-file input_params.yaml
```

## Outputs

Results are written under `output_folder` and published into these locations:

- `output/qc/`
	- `*_fastqc.zip`
	- `*_fastqc.html`
	- `multiqc_report.html`
- `output/bam/`
	- `<sample_name>.sorted.bam`
	- `<sample_name>.sorted.bam.bai`
- `output/phasing/`
	- `<sample_name>_phased.vcf.gz`
	- `<sample_name>_phased.vcf.gz.tbi`
	- `<sample_name>_haplotagged.bam`

The workflow also produces execution and timeline reports in:

- `output/reports/execution_report.html`
- `output/reports/timeline_report.html`

## Notes

- The workflow currently expects FASTQ input and does not invoke basecalling from `main.nf`.
- The workflow manifest metadata is defined in [nextflow.config](nextflow.config).
