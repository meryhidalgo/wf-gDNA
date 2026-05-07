#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process basecall {
    tag "${pod5}"

    input:
        path pod5_dir
    output:
        path "pass/*.gz"

    """
    pod5_dir \\
    -i ${fast5_dir} \\
    -s . \\
    -c ${params.config_file} \\
    --device auto \\
    --compress_fastq \\
    --num_callers ${task.cpus} \\
    --chunks_per_caller 400
    """
}