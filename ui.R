shinyUI(
  fluidPage(
    useShinyjs(),
    titlePanel("EDA 2 - Arijit Bhattacharjee"),
    
    tabsetPanel(
      tabPanel("Summary",
               htmlOutput("profileSummary")
               
      ),
      
      tabPanel("Raw Data",
                DT::dataTableOutput(outputId = "data_file")
              ),
      
      tabPanel(" Pairs Plot",
                              sidebarLayout(
                                sidebarPanel(
                                  width =2,
                                  sliderInput(inputId = "VarThreshold_pairs", label = "Threshold of variable missingness", 
                                              min = 1, max = 100, value = 25, post = "%"),
                                  sliderInput(inputId = "ObsThreshold_pairs", label = "Threshold of observations missingness", 
                                              min = 1, max = 100, value = 25, post = "%"),
                                  checkboxGroupInput("show_vars_pairs", "Graphs in dat to show:",
                                                     names(dat[-c(1,16:25)]), selected = choicesB),
                                  selectInput(inputId = "Color", label = "Colouring based on (Select the same column up as well)", choices = choicesC, multiple = FALSE, selected = "HEALTHCARE_BASIS")
                                ),
                                mainPanel(
                                  width =10,
                                  withSpinner(
                                    plotOutput(outputId = "Pairs", height = 600)
                                  ),
                                  
                                )
                              )
                     ),


        tabPanel("Correlation",
                            checkboxInput(inputId = "abs", label = "Uses absolute correlation", value = TRUE),
                            selectInput(inputId = "CorrMeth", label = "Correlation method", choices = c("pearson","spearman","kendall"), selected = "pearson"),
                            selectInput(inputId = "Group", label = "Grouping method", choices = list("none" = FALSE,"OLO" = "OLO","GW" = "GW","HC" = "HC"), selected = "OLO"),
                            hr(),
                            withSpinner(
                              plotOutput(outputId = "Corrgram")
                        )
               ),
      
      tabPanel("Boxplot for Variables",
                              sidebarLayout(
                                sidebarPanel(
                                  width =2,
                                  checkboxGroupInput("show_vars4", "Box plots in dat to show:",
                                                     names(dat[,c(3:11,13)]), selected = choicesA)
                                ),
                                mainPanel(
                                  width =10,
                                  checkboxInput(inputId = "standardise", label = "Show standardized", value = TRUE),
                                  checkboxInput(inputId = "outliers", label = "Show outliers", value = TRUE),
                                  sliderInput(inputId = "range", label = "IQR Multiplier", min = 0, max = 5, step = 0.1, value = 1.5),
                                  hr(),
                                withSpinner(
                                  plotOutput(outputId = "Boxplot", height = 600)  
                                  )
                                )
                              )
                     ),

    tabPanel("Data Gaps",
                        withSpinner(
                          plotOutput(outputId = "Rising")
                        ),
                        checkboxInput(inputId = "standardise2", label = "Show standardized", value = TRUE),
                        selectInput(inputId = "Graph", label = "Compare with", choices = choicesA, multiple = TRUE, selected = "POPULATION")
               ),

      tabPanel("Homogeneity Plot",
               withSpinner(
                 plotOutput(outputId = "Homogeneity", height = 600)
               ),
               checkboxInput(inputId = "standardise3", label = "Show standardized", value = FALSE),
               selectInput(inputId = "Graph2", label = "Variables to chart", choices = choicesA, multiple = TRUE, selected = choicesA)
      ),
      
    tabPanel("Missing Data",
               sidebarLayout(
                 sidebarPanel(
                   sliderInput(inputId = "VarThreshold_miss", label = "Threshold of variable missingness", 
                               min = 1, max = 100, value = 50, post = "%"),
                   sliderInput(inputId = "ObsThreshold_miss", label = "Threshold of observations missingness", 
                               min = 1, max = 100, value = 50, post = "%"),
                 ),
                 mainPanel(
                   withSpinner(
                     plotOutput(outputId = "Missing")
                   ),
                   withSpinner(
                     plotOutput(outputId = "Missing2")
                                    ),
                   checkboxInput(inputId = "cluster", label = "Cluster missingness", value = FALSE)
                 )
               )
               
      ),

     tabPanel("Missing data visualisation",
         withSpinner(
           plotOutput(outputId = "Miss", height = 600)
         )
      ),


    tabPanel("Missingness Pattern",
         withSpinner(
           plotOutput(outputId = "Missingness")
         )
    ),
      
      tabPanel("Model Summary and Prediction",
               sidebarLayout(
                 sidebarPanel(
                   sliderInput(inputId = "VarThreshold", label = "Threshold of variable missingness", 
                               min = 1, max = 100, value = 50, post = "%"),
                   sliderInput(inputId = "ObsThreshold", label = "Threshold of observations missingness", 
                               min = 1, max = 100, value = 50, post = "%"),
                   selectInput(inputId = "ImpMethod", label = "Imputation method", 
                               choices = c("Tree based", "KNN", "Partial Del","Median"), selected = "KNN"),
                   selectInput(inputId = "split_data", label = "Data set to predict on", 
                               choices = c("Test", "Train", "Complete data"), selected = "test"),
                   actionButton(inputId = "Go", label = "Train Model", icon = icon("play"))
                 ),
                 mainPanel(
                   withSpinner(
                     verbatimTextOutput(outputId = "Summary_model")
                   ),
                   withSpinner(
                     verbatimTextOutput(outputId = "Predictions")
                   ),
                   withSpinner(
                     plotOutput(outputId = "Predictionplot")
                   ),
                   withSpinner(
                     verbatimTextOutput(outputId = "RMSE")
                   )
                 )
               )
               
      ),

      tabPanel("Residual Boxplot",
               sliderInput(inputId = "range2", label = "IQR Multiplier", min = 0, max = 5, step = 0.1, value = 1.5),
               withSpinner(
                 plotOutput(outputId = "Res")
               )
           )
      
    )
  )
)
