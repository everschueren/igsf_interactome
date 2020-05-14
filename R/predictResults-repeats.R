library(Rplates)

####################################
## READ
###################################

VERSION <- 'igsf_interactome_1_0'
OUTPUTDIR <- sprintf('inst/extdata/%s', VERSION)
IGSF_SCORE_FILE <- sprintf('%s/%s_score_file.txt', OUTPUTDIR, VERSION)
gold_standards_pos_file <- 'inst/extdata/igsf_trainingset_POS.txt'
gold_standards_sticky_file <- 'inst/extdata/igsf_trainingset_STICKY.txt'

####################################
## DATA PROCESSING CONFIG
#####################################

set.seed(42)

FILTER_POS_SET_BY_SIGNAL <- T
SAMPLE_NEGATIVES <- T
SAMPLE_NEGATIVE_MULTIPLIER <- 10
HUMAN_MODEL <- T
PCA <- T
KMEANS <- T
HIT_QUANTILE_THRESHOLD <- .99
PREDICT_PPI_WITH_SIGNAL_ONLY <- F
SUPERVISED <- T
UNSUPERVISED <- T
ggplot2::theme_set(ggplot2::theme_bw(base_size = 14, base_family = 'Helvetica'))

####################################
## DATA PREP
#####################################

### read in data & gold standards
IGSF_SCORED <- fread(IGSF_SCORE_FILE)
goldstandards_POS <- data.table::fread(gold_standards_pos_file)
goldstandards_STICKY <- data.table::fread(gold_standards_sticky_file)

##  to do : turn this into a list returning model AND predicted hits
## then write out the model, and make a new function that can use the model

IGSF_PREDICTIONS <- Rplates::main.predict.supervised(IGSF_SCORED, 
                                                     goldstandards_POS,
                                                     goldstandards_STICKY,
                                                     FILTER_POS_SET_BY_SIGNAL, 
                                                     SAMPLE_NEGATIVES,
                                                     SAMPLE_NEGATIVE_MULTIPLIER, 
                                                     HIT_QUANTILE_THRESHOLD, 
                                                     PREDICT_PPI_WITH_SIGNAL_ONLY)

## 1) positive results only
IGSF_PREDICTIONS <- IGSF_PREDICTIONS %>%
  dplyr::mutate(predictedClass = ifelse(STICKY <= .25 &
                                          POS >=.75 &
                                          NEG <= .05 &
                                          intensity >= .2 & 
                                          !grepl(pattern = 'CTRL', prey_short_name),
                                        'POS-HICONF',
                                        as.character(aggregated_results.predictionClasses)))

write.table(IGSF_PREDICTIONS,
            file=paste(OUTPUTDIR, VERSION, '_prediction_file.txt', sep=''),
            eol='\n', sep='\t', quote=F, row.names=F, col.names = T)

Rplates::printModelSummary(IGSF_PREDICTIONS %>% dplyr::filter(predictedClass == 'POS-HICONF'))
