process clair3 {

    container "hkubal/clair3:latest"

    //publishDir "${params.output_folder}/phasing",
    //    mode: 'copy'

    input:
        tuple path(bam), path(bai)
        path reference
        path bedfile

    output:
        // path "clair3/merge_output.vcf.gz"
        tuple path("clair3/merge_output.vcf.gz"), path("clair3/merge_output.vcf.gz.tbi")

    script:
    """
    MODEL_NAME="r1041_e82_400bps_sup_v500"

    run_clair3.sh \
        --bam_fn=${bam} \
        --ref_fn=${reference} \
        --threads=4 \
        --platform=ont \
        --model_path=/opt/models/\${MODEL_NAME} \
        --bed_fn=${bedfile} \
        --output=clair3

    tabix -p vcf clair3/merge_output.vcf.gz
    """
}

process whatshap {

    container "jlalli/whatshap:2.1"

    publishDir "${params.output_folder}/phasing",
        mode: 'copy'

    input:
        tuple path(vcf), path("${vcf}.tbi")
        tuple path(bam), path(bai)
        tuple path(reference), path("${reference}.fai")

    output:
        path "${params.sample_name}_phased.vcf.gz", emit: phased_vcf
        path "${params.sample_name}_haplotagged.bam", emit: hap_bam

    script:
    """
    whatshap phase \
        -o ${params.sample_name}_phased.vcf \
        --reference ${reference} \
        ${vcf} \
        ${bam} \
        --ignore-read-groups

    bcftools view -Oz -o ${params.sample_name}_phased.vcf.gz ${params.sample_name}_phased.vcf
    bcftools index ${params.sample_name}_phased.vcf.gz

    whatshap haplotag \
        -o ${params.sample_name}_haplotagged.bam \
        --reference ${reference} \
        ${params.sample_name}_phased.vcf.gz \
        ${bam} \
        --ignore-read-groups \
        --output-haplotag-list "haplotag-list.txt"

    """
}
