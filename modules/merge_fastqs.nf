process merge_fastqs {
    publishDir "${params.output_dir}/fastqs/basecalled",
        mode: 'copy',
        enabled: params.publish_basecalled

    input:
        path fastqs
    output:
        path "out/merged.fastq.gz"

    """
    mkdir out
    cat *.fastq.gz > out/merged.fastq.gz
    """
}