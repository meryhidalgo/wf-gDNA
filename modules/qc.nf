process fastqc {

    container "quay.io/biocontainers/fastqc:0.11.9--hdfd78af_1"

    publishDir "${params.output_folder}/qc",
        mode: 'copy'

    input:
        path fastq

    output:
        path "*_fastqc.zip"
        path "*_fastqc.html"

    script:
    """
    fastqc ${fastq}
    """
}


process multiqc {

    container "quay.io/biocontainers/multiqc:1.11--pyhdfd78af_0"

    publishDir "${params.output_folder}/qc",
        mode: 'copy'
    
    input:
        path "*_fastqc.zip"
        path "*_fastqc.html"

    output:
        path "multiqc_report.html"

    script:
    """
    multiqc .
    """

}