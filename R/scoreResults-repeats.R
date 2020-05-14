library(Rplates)

##########################
### CONFIGURE INPUT/OUTPUT

VERSION <- 'igsf_interactome_1_0'
OUTPUTDIR <- sprintf('inst/extdata/%s', VERSION)
IGSF_DATA_FILE_FILTERED <- sprintf('inst/extdata/%s_data_file_filtered.txt', VERSION)
if(!dir.exists(OUTPUTDIR)) dir.create(OUTPUTDIR)

### CONFIGURE PARAMS
HIT_QUANTILE_THRESHOLD <- .95
CORRECT_BACKGROUND <- T
SCALE_TO_MAX <- T
SCALE_MINMAX_PER_BAIT <- F
MINMAX_SCALE <- F
PLATE_VIZ <- F
PLOT_DIR <-  paste(OUTPUTDIR, 'plates/', sep='/')
FLATTEN_IDENTICAL_PREYS <- T

if(!dir.exists(PLOT_DIR)) dir.create(PLOT_DIR)
IGSF_DATA <- fread(IGSF_DATA_FILE_FILTERED)
IGSF_DATA_W_FEATURES <- Rplates::main.aggregateScores(result_table_ann=IGSF_DATA, 
                                                      MINMAX_SCALE = MINMAX_SCALE, 
                                                      hit_quantile_threshold = HIT_QUANTILE_THRESHOLD, 
                                                      CORRECT_BACKGROUND = CORRECT_BACKGROUND, 
                                                      SCALE_TO_MAX = SCALE_TO_MAX, 
                                                      SCALE_MINMAX_PER_BAIT=SCALE_MINMAX_PER_BAIT, 
                                                      PLATE_VIZ = PLATE_VIZ, 
                                                      PLOT_DIR, 
                                                      FLATTEN_IDENTICAL_PREYS = FLATTEN_IDENTICAL_PREYS)

### WRITE IT ALL BACK OUT
Rplates::main.writeScores(results = IGSF_DATA_W_FEATURES, 
                          file=paste0(OUTPUTDIR, VERSION, '_score_file.txt'), subset = F)



