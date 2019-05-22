import "https://raw.githubusercontent.com/abelhj/sv-pipeline/terra_sv/scripts/SV_Tasks.wdl" as SV

workflow Pre_Merge_SV_Per_Sample {
  # data inputs
  File aligned_cram

  # reference inputs
  File ref_fasta
  File ref_fasta_index
  File ref_cache
  File? call_regions_bed
  File? call_regions_bed_index
  File exclude_regions
  
  String aligned_cram_suffix

  # system inputs
  Int preemptible_tries

  String basename = sub(sub(aligned_cram, "^.*/", ""), aligned_cram_suffix + "$", "")

  call SV.Index_Cram {
    input:
    basename = basename,
    input_cram = aligned_cram,
    ref_cache = ref_cache,
    preemptible_tries = preemptible_tries
  }

  call SV.Manta {
    input:
    basename = basename,
    input_cram = aligned_cram,
    input_cram_index = Index_Cram.output_cram_index,
    ref_fasta = ref_fasta,
    ref_fasta_index = ref_fasta_index,
    call_regions_bed = call_regions_bed,
    call_regions_bed_index = call_regions_bed_index,
    ref_cache = ref_cache,
    preemptible_tries = preemptible_tries
  }

  call SV.CNVnator_Histogram {
    input:
    basename = basename,
    input_cram = aligned_cram,
    input_cram_index = Index_Cram.output_cram_index,
    ref_fasta = ref_fasta,
    ref_fasta_index = ref_fasta_index,
    ref_cache = ref_cache,
    preemptible_tries = preemptible_tries
  }

  call SV.Smoove {
    input:
    basename = basename,
    input_cram = aligned_cram,
    input_cram_index = Index_Cram.output_cram_index,
    ref_fasta = ref_fasta,
    ref_fasta_index = ref_fasta_index,
    ref_cache = ref_cache,
    exclude_regions = exclude_regions,
    preemptible_tries = preemptible_tries
  }

  output {
    File cram_index = Index_Cram.output_cram_index
    File manta_vcf = Manta.output_vcf
    File manta_tbi = Manta.output_tbi
    File cnvnator_cn_hist_root = CNVnator_Histogram.output_cn_hist_root
    File cnvnator_output_cn_txt = CNVnator_Histogram.output_cn_txt
    File cnvnator_cn_bed = CNVnator_Histogram.output_cn_bed
    File smoove_vcf = Smoove.output_vcf
    File smoove_csi = Smoove.output_csi
  }
}
