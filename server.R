pMiss <- function(x){ sum(is.na(x))/length(x)*100 }

shinyServer(function(input, output, session) {
  
  onSessionEnded(function() {
    stopApp()
  })

# Summary of data    
  output$profileSummary <- renderUI({
    print(dfSummary(dat[1:15]),                                    
          method = "render") 
  })
  
# Raw data  
  output$data_file <- DT::renderDataTable({
        DT::datatable(dat[1:15])
      })

# GGplot    
  getCleanData_pairs1 <- reactive({
    # remove excessively missing Vars
    data_pairs <- dat[, input$show_vars_pairs, drop = FALSE]
    vRatio <- apply(X = data_pairs, MARGIN = 2, FUN = pMiss)
    data_pairs[, vRatio < input$VarThreshold_pairs]
  })
  
  getCleanData_pairs2 <- reactive({
    # remove excessively missing Obs
    data_pairs <- getCleanData_pairs1()
    oRatio <- apply(X = data_pairs, MARGIN = 1, FUN = pMiss)
    data_pairs[oRatio < input$ObsThreshold_pairs, ]
  }) 

  output$Pairs <- renderPlot({
      GGally::ggpairs(getCleanData_pairs2(), title = "Pairs Plot", aes_string(color=if(input$Color!="None") input$Color else NULL), progress = FALSE)
    })
    
#Correlation    
  output$Corrgram <- renderPlot({
        corrgram(dat[-c(1,16:25)], 
                 order = input$Group, 
                 abs = input$abs, 
               cor.method = input$CorrMeth,
                 lower.panel=panel.shade,
                 upper.panel=panel.shade,
    
                 text.panel = panel.txt,
                 main = "Correlation Plot")
      })
  
#Boxplot for variables    
  output$Boxplot <- renderPlot({
    data <- as.matrix(dat[, input$show_vars4, drop = FALSE])
    data <- scale(data, center = input$standardise, scale = input$standardise)
    car::Boxplot(y = data, ylab = NA, use.cols = TRUE, notch = FALSE, varwidth = FALSE,  
                  horizontal = FALSE, outline = input$outliers, 
                  range = input$range, main = "Boxplots of numeric data",
                  id = ifelse(input$outliers, list(n = Inf, location = "avoid"), FALSE))
      }) 

#Gaps in data    
    output$Rising <- renderPlot({
      cols <- c('DEATH_RATE',input$Graph)
      d <- dat[,cols]  # select the definitely-continuous columns
      for (col in 1:ncol(d)) {
        d[,col] <- d[order(d[,col]),col] #sort each column in ascending order
      }
      d <- scale(x = d, center = input$standardise2, scale = input$standardise2)
      mypalette <- rainbow(ncol(d))
      matplot(x = seq(1, 100, length.out = nrow(d)), y = d, type = "l", xlab = "Percentile", ylab = "Values", lty = 1, lwd = 1, col = mypalette, main = "Rising value chart")
      legend(legend = colnames(d), x = "topleft", y = "top", lty = 1, lwd = 1, col = mypalette, ncol = round(ncol(d)^0.3))
    })
    
#Homogeneity plot
      output$Homogeneity <- renderPlot({
        cols <- input$Graph2 # choose the numeric columns
        numData <- scale(dat[,cols], center = input$standardise3, scale = input$standardise3) 
        matplot(numData, type = "l", col = rainbow(ncol(numData)), xlab = "Observations in sequence", ylab = "Value", main = "Matplot")
      })
      
     
#Missing data chart   
  getCleanData_miss1 <- reactive({
    # remove excessively missing Vars
    data_miss <- dat
    vRatio <- apply(X = data_miss, MARGIN = 2, FUN = pMiss)
    data_miss[, vRatio < input$VarThreshold_miss]
  })
  
  getCleanData_miss2 <- reactive({
    # remove excessively missing Obs
    data_miss <- getCleanData_miss1()
    oRatio <- apply(X = data_miss, MARGIN = 1, FUN = pMiss)
    data_miss[oRatio < input$ObsThreshold_miss, ]
  }) 
  
  output$Missing <- renderPlot({
    visdat::vis_dat(getCleanData_miss2()) +
      labs(title = paste("Thresholds VarMiss:", input$VarThreshold_miss, " and ObsMiss:", input$ObsThreshold_miss))
  }, width = 1000)
  
  output$Missing2 <- renderPlot({
    vis_miss(getCleanData_miss2(), cluster = input$cluster)
  }, width = 1000)
  
  
# Missing data visualization  
  output$Miss <- renderPlot({
      naniar::gg_miss_upset(data = dat, nsets = 10) 
    })
  
# Missingness pattern
  output$Missingness <- renderPlot({
    dat$MISSINGNESS <- apply(X = is.na(dat), MARGIN = 1,FUN = sum)
    tree <- train(MISSINGNESS ~ . -CODE,data = dat, method = "rpart", na.action = na.rpart)
    rpart.plot(tree$finalModel, main = "TUNED: Predicting the number of missing variables in an observation",
               roundint = TRUE, clip.facs = TRUE)
  })


# Model to be trained on train data
#Train model using recipe based processing pipeline and reactive expression
  
  getData <- reactive({
    train
  })
  
  getCleanData1 <- reactive({
    # remove excessively missing Vars
    data <- getData()
    vRatio <- apply(X = data, MARGIN = 2, FUN = pMiss)
    data[, vRatio < input$VarThreshold]
  })
  
  getCleanData2 <- reactive({
    # remove excessively missing Obs
    data <- getCleanData1()
    oRatio <- apply(X = data, MARGIN = 1, FUN = pMiss)
    data[oRatio < input$ObsThreshold, ]
  }) 

  getRecipe <- reactive({
    rec <- recipes::recipe( DEATH_RATE ~ ., getCleanData2())%>%
      update_role("CODE", new_role = "id") %>%
      update_role("OBS_TYPE", new_role = "split")%>%
      update_role("POPULATION_SHADOW", new_role = "Predictor") %>%
      update_role("AGE25_PROPTN_SHADOW", new_role = "Predictor") %>%
      update_role("AGE_MEDIAN_SHADOW", new_role = "Predictor") %>%
      update_role("AGE50_PROPTN_SHADOW", new_role = "Predictor") %>%
      update_role("POP_DENSITY_SHADOW", new_role = "Predictor") %>%
      update_role("GDP_SHADOW", new_role = "Predictor") %>%
      update_role("INFANT_MORT_SHADOW", new_role = "Predictor") %>%
      update_role("DOCS_SHADOW", new_role = "Predictor") %>%
      update_role("VAX_RATE_SHADOW", new_role = "Predictor") %>%
      update_role("HEALTHCARE_COST_SHADOW", new_role = "Predictor") %>%
      step_zv(all_predictors()) #remove all constant columns

# Impute option selection        
    rec <- switch (input$ImpMethod,
                     "KNN" = step_impute_knn(rec, all_predictors(), neighbors = 5),
                     "Median" = step_impute_median(rec, all_numeric_predictors()),
                     "Partial Del" = step_naomit(rec, all_predictors(), skip = TRUE),
                     "Tree based" = step_impute_bag(rec, all_predictors())
      )

    rec <- step_center(rec, all_numeric_predictors()) %>%  # centering all numeric predictors
      step_scale(all_numeric_predictors()) %>%   # scaling all numeric predictors          
      step_dummy(all_nominal_predictors()) %>%   # encoding all nominal predictors as dummy variables
      step_rm(all_nominal_predictors()) %>% #remove any nominals
      step_nzv(all_predictors()) %>%  # remove near zero variance predictor variables
      step_lincomb(all_numeric_predictors())  # remove predictors that are linear combinations of other predictors
    rec
  })
  
 # Training model 
  getModel <- reactive({
    req(input$Go)
    isolate({
      caret::train(getRecipe(), 
                   data = getCleanData2(), 
                   method = "glmnet") 
    })
  })
  
# Get model summary
  output$Summary_model <- renderPrint({
    req(getModel())
    getModel()
  })
  
#Get predictions based on user input and plot 
  getPredictions <- reactive({
  if (input$split_data == "Test") {
      data_predict <- test
          } else if (input$split_data == "Train") {
            data_predict <- train
          } else if (input$split_data == "Complete data") {
            data_predict <- dat
          }
    predict(getModel(),data_predict)
  })
  
  output$Predictions <- renderPrint({
    getPredictions()
  })
  
  output$Predictionplot <- renderPlot({
    if (input$split_data == "Test") {
      data_predict <- test
    } else if (input$split_data == "Train") {
      data_predict <- train
    } else if (input$split_data == "Complete data") {
      data_predict <- dat
    }
    rang <- range(c(data_predict$DEATH_RATE, getPredictions()))
    ggplot(data = data_predict) +
      geom_point(mapping = aes(x = data_predict$DEATH_RATE, y = getPredictions())) + 
      geom_abline(slope = 1, col = "blue") +
      labs(title = "Death rate predictions ", y = "predicted", x = "actual") +
      coord_fixed(ratio = 1, xlim = rang, ylim = rang, expand = TRUE)
  })

# Calculate RMSE statistic  
  output$RMSE <- renderPrint({
    if (input$split_data == "Test") {
      data_predict <- test
    } else if (input$split_data == "Train") {
      data_predict <- train
    } else if (input$split_data == "Complete data") {
      data_predict <- dat
    }
    req(getPredictions())
    print(paste("RMSE statistic for",input$split_data))
    sqrt(mean((data_predict$DEATH_RATE - getPredictions())^2))
  }) 
  
  
# Plot residual boxplot based on user input
  output$Res <- renderPlot({
    if (input$split_data == "Test") {
      data_predict <- test
    } else if (input$split_data == "Train") {
      data_predict <- train
    } else if (input$split_data == "Complete data") {
      data_predict <- dat
    }
    residuals <- data_predict$DEATH_RATE - getPredictions()
    names(residuals) <- rownames(data_predict)
    
    coef <- input$range2
    limits <- boxplot.stats(x = residuals, coef = coef)$stats
    label <- ifelse(residuals < limits[1] | residuals > limits[5], names(residuals), NA)
    data_res <- data.frame(residuals, label)
    ggplot(data_res, mapping = aes(x = residuals, y = 0)) +
      geom_boxplot(coef = coef, outlier.colour = "red") +
      ggrepel::geom_text_repel(max.overlaps = 50, mapping = aes(label = label)) +
      
      labs(title = paste("Boxplot using", coef, "as IQR Multiplier and showing", input$split_data ,"residuals.\n(To change the residual plot please switch between Test/Train/Complete data on Model Summary and Prediction tab)")) +
      theme(axis.title.y = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank())
  })
  
})