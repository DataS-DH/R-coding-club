source("Demo/libraries.R")

##-----------------------------------------------------------------------------
## This template is installed from the a11ytables addin: 
## Insert Full 'a11ytables' template workflow

# Prepare tables

cover_df <- tibble::tribble(
  ~"subsection_title",  ~"subsection_content",
  "Description", "Data tables to accompany the published report: Blah blah blah", # amended from template
  "Contact for general enquiries", "pha-ohid@dhsc.gov.uk",                        # amended from template 
  "Contact for press enquiries", "pressofficenewsdesk@dhsc.gov.uk",
  "Publication Date", "29 November 2022", 
  "Version", substring(system("git rev-parse HEAD", intern=TRUE),1,8)             # adds Git version
)

  contents_df <- tibble::tribble(
    ~"Sheet name", ~"Sheet title",
    "Notes", "Notes",
    "Table_1", "Example sheet title"
  )

  notes_df <- tibble::tribble(
    ~"Note number", ~"Note text",
    "[note 1]", "Placeholder note.",
    "[note 2]", "Placeholder note."
  )

  table_df <- mtcars
  table_df[["car [note 1]"]] <- row.names(mtcars) # creates column using row names and adds column-level note 1
  row.names(table_df) <- NULL                                  # removes row names
  table_df <- table_df[1:5, c("car [note 1]", "mpg", "cyl")]   # reduces rows and columns for demo
  table_df["Notes"] <- c("[note 2]", rep(NA_character_, 4))    # adds record-level note 2

# Create new a11ytable

my_a11ytable <-
    a11ytables::create_a11ytable(
      tab_titles = c(
        "Cover",
        "Contents",
        "Notes",
        "Table_1"
      ),
      sheet_types = c(
        "cover",
        "contents",
        "notes",
        "tables"
      ),
      sheet_titles = c(
        "Cover title (example)",
        "Contents",
        "Notes",
        "Example sheet title"
      ),
      blank_cells = c(
        NA_character_,
        NA_character_,
        NA_character_,
        "Blank cells mean that a row does not have a note."
      ),
      sources = c(
        NA_character_,
        NA_character_,
        NA_character_,
        "Example source."
      ),
      tables = list(
        cover_df,
        contents_df,
        notes_df,
        table_df
      )
    )

# Generate workbook from a11ytable

my_wb <- a11ytables::generate_workbook(my_a11ytable)

# get the latest Git Commit
gitCommit <- substring(system("git rev-parse HEAD", intern=TRUE),1,8)   # add Git commit version to filename

# Create output with Git commit in filename
openxlsx::saveWorkbook(
  my_wb,
  paste0("Demo/EditedExample_", gitCommit, ".xlsx")
)

