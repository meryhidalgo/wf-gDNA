
process minimap2 {

   container "staphb/minimap2:latest"

     input:
         path fastq
         path genome_fasta

     output:
         path "*.sam"

     script:
     """
     minimap2 -ax map-ont ${genome_fasta} ${fastq}  > {params.sample_name}.sam
     """
     //  samtools index bam/aligned.sam
}

