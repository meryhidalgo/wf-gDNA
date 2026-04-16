#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

// All of the default parameters are being set in `nextflow.config`

// Import sub-workflows
include { basecall } from './modules/basecall'

include { fastqc } from './modules/fastqc'

include { merge_fastqs } from './modules/merge_fastqs'


// include { quality_wf } from './modules/quality'
// include { align_wf } from './modules/align'


// Function which prints help message text
def helpMessage() {
    log.info"""
Usage:

nextflow run wf-gDNA -params-file input_params.yaml

Required Input Params:

  Input Data:
    fastq_folder        Folder containing FASTQ files ending with .fastq.gz
    enable_basecalling  true or false. Default: false. If true, pod5_folder must be provided
    pod5_folder         Folder containing pod5 files ending with .pod5

  Reference Data:
    genome_fasta        Reference genome to use for alignment, in FASTA format

  Output Location:
    output_folder       Folder for output files

  Optional Arguments:
    min_qvalue          Minimum quality score used to trim data (default: ${params.min_qvalue})
    min_align_score     Minimum alignment score (default: ${params.min_align_score})
    """.stripIndent()
}



// ------------ INPUT FILES ------------

if (params.enable_basecalling) {

}

// Main workflow
workflow {

    // Show help message if the user specifies the --help flag at runtime
    // or if any required params are not provided
     if ( params.help || params.output_folder == false || params.genome_fasta == false ){
         Invoke the function above which prints the help message
         helpMessage()
         Exit out and do not run anything else
        exit 1
     }

    /* ----- BASECALLING ----- */
    if (params.enable_basecalling) {
        Channel
            .fromPath("${params.pod5_folder}/*.pod5")
            .set{pod5_files}
        Channel
            .fromPath(params.pod5_folder, type: 'dir')
            .set{pod5_folder}

        pod5_folder \
        | basecall \
        | collect \
        | merge_fastqs \
        | set { fastq_file }
    } else {
        Channel
            .fromPath("$params.fastq_folder/*.fastq.gz") \
            | set { fastq_file }
    }

    // Perform quality trimming on the input 
    quality_wf(
        fastq_ch
    )
    // output:
    //   reads:
    //     tuple val(specimen), path(read_1), path(read_2)

    // Align the quality-trimmed reads to the reference genome
    align_wf(
        quality_wf.out.reads,
        file(params.genome_fasta)
    )
    // output:
    //   bam:
    //     tuple val(specimen), path(bam)

}