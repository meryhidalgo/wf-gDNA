process merge_fastqs {
    publishDir "${params.output_folder}",
        mode: 'copy'

    input:
        path fastqs
    output:
        path "fastq/${params.sample_name}.fastq.gz"

    script:
    """
    mkdir fastq
    zcat ${fastqs} | gzip > fastq/${params.sample_name}.fastq.gz
    """
}