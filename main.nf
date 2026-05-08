#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// All of the default parameters are being set in `nextflow.config`

// Import sub-workflows
include { basecall } from './modules/basecall'

include { fastqc; multiqc } from './modules/qc'

include { merge_fastqs } from './modules/merge_fastqs'
include { minimap2 } from './modules/align'
include { samtools_index; samtools_index as samtools_index2; samtools_faidx } from './modules/samtools'

include { clair3; whatshap } from './modules/phasing'

// Function which prints help message text
def helpMessage() {
    log.info"""
        Usage:

        nextflow run wf-gDNA -params-file input_params.yaml

        Required Input Params:

          Input Data:
            fastq_folder        Folder containing FASTQ files ending with .fastq.gz
            sample_name         Sample name to use for output files

          Reference Data:
            genome_fasta        Reference genome to use for alignment, in FASTA format
            bedfile             BED file specifying regions to call variants in, in BED format

          Output Location:
            output_folder       Folder for output files
 """.stripIndent()
}


// ------------ INPUT FILES ------------

// Main workflow
workflow {

    // Show help message if the user specifies the --help flag at runtime
    // or if any required params are not provided
     if ( params.help || params.fastq_folder == false || params.genome_fasta == false ){
         // Invoke the function above which prints the help message
        helpMessage()
        // Exit out and do not run anything else
        exit 1
     }
     // ---- Input files ----
      reference = channel.fromPath(params.genome_fasta, checkIfExists: true)
      bedfile = channel.fromPath(params.bedfile, checkIfExists: true)
      fastqs = channel.fromPath("${params.fastq_folder}/*.fastq.gz", checkIfExists: true)

    merge_fastqs(fastqs) | set { fastq_file }

     fastqc(fastq_file)
     multiqc(fastqc.out)

    bam_ch = minimap2(fastq_file, reference) \
        | samtools_index

    // STEP 1: Clair3
    vcf_ch = clair3(
        bam_ch,
        reference,
        bedfile
    )
    
    // STEP 2: WhatsHap phase and haplotag
    // fai = samtools_faidx(file(params.genome_fasta))
    reference_ch = samtools_faidx(
        reference
    )
    whatshap_out = whatshap(
        vcf_ch,
        bam_ch,
        reference_ch
    )

    whatshap_out.hap_bam | samtools_index2


    // output:
    //   bam:
    //     tuple val(specimen), path(bam)

}