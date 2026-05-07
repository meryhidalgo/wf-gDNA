process samtools_index {

    container "staphb/samtools:latest"

     publishDir "${params.output_folder}/bam",
        mode: 'copy'

     input:
        path sam

    output:
        tuple path("${params.sample_name}.sorted.bam"), path("${params.sample_name}.sorted.bam.bai")

     script:
     """
     samtools sort -o ${params.sample_name}.sorted.bam ${sam}
     samtools index ${params.sample_name}.sorted.bam
     """
}

process samtools_faidx {

    container "staphb/samtools:latest"

    input:
        path reference_fa

    output:
        tuple path(reference_fa), path("${reference_fa}.fai")

     script:
     """
     samtools faidx ${reference_fa}
     """
}
