"""
Sunspot Data Cleaning Functions

Functions to clean the sunspot data ready for use.
Includes the redundant function create_datetime_column_ymd which has been superceded by create_datetime_column_flex
This script is used in the notebook Code_QA_best_practice and the script sunspot_analysis_functions.py

"""
import pandas as pd


def tidy_data_cols(raw_data, cols_to_drop):
    """
    This function tidies the columns in the raw dataframe, changing the names to lower case and removing unwanted columns.
    
    Parameters
    ----------
    df: a dataframe of the sunspot data. Must have lower case column headings
    cols_to_drop: a list of column indexes to be removed
    
    Returns
    -------
    df: the new dataframe with updated columns
    """
    
    # Change the column names to lower case
    raw_data.columns = raw_data.columns.str.lower()
    
    # Drop unnecessary columns
    df = raw_data.drop(cols_to_drop,axis = 1)
    
    return df


def create_datetime_column_ymd(df):
    """
    This function creates a combined datetime column from the separate columns year, month, day
    
    Parameters
    ----------
    df: a dataframe of the sunspot data with separate date columns 
    
    Returns
    -------
    new_df: the dataframe with the new merged datetime column
    """
    
    new_df = df.assign(datetime = pd.to_datetime(df['year', 'month', 'day']))
    
    return new_df

def create_datetime_column_flex(df, datetime_cols):
    """
    This function creates a combined datetime column from the separate columns. It's a more 
    flexible version of create_datetime_column_ymd and accepts ymd, ym or y as input to create a datetime column
    
    Parameters
    ----------
    df: a dataframe of the sunspot data with separate date columns 
    datetime_cols: a list of the datetime columns to be combined for the merged datetime column 
    
    Returns
    -------
    new_df: the dataframe with the new merged datetime column
    
    Notes
    -----
    Only works with year, month, day; year and month or year only, not any other combination of input datetime values
    """
    
    if len(datetime_cols) == 3:
        new_df = df.assign(datetime = pd.to_datetime(df[datetime_cols]))
    if len(datetime_cols) == 2:
        new_df = df.assign(datetime = pd.to_datetime(df['month'].astype('string')+'-'+df['year'].astype('string')))
    if len(datetime_cols) == 1:
        new_df = df.assign(datetime=pd.to_datetime(df['year'].astype('string')))
    
    return new_df

    
def remove_nulls_and_no_obs(df, not_null_col):
    """
    This function removes rows of the dataframe where the value in a particular column is null or =-1 
    (For daily sunspot number -1 means that no observations were made that day).
    
    Parameters
    ----------
    df: a dataframe of the sunspot data. 
    not_null_col: a string of the name of the column to be assessed
    
    Returns
    -------
    new_df: the new dataframe with relevant rows removed
    """
    
    # Remove rows when value is null
    new_df = df[df[not_null_col].notnull()]
    
    # Remove rows when value is -1
    new_df = new_df[~(new_df[not_null_col] == -1)]
    
    return new_df


def clean_raw_data(raw_data, cols_to_drop, datetime_cols, not_null_col):
    """
    This function cleans the raw sunspot data for analysis. It tidies the columns, 
    creates a single merged datetime column and removes nulls.
    
    Parameters
    ----------
    raw_data: a dataframe of the initial sunspot data
    columns_to_drop: a list of column indexes to be removed
    datetime_cols: a list of the datetime columns to be combined for the merged datetime column
    not_null_col: a string of the name of the column to be assessed as null or not
        
    Returns
    --------
    clean_sunspot_data: a dataframe of the cleaned data
    """
    
    # Tidy the columns
    df = tidy_data_cols(raw_data, cols_to_drop)
    
    # Create a merge datetime column from year, month, day
    df = create_datetime_column_flex(df, datetime_cols)
    
    # Remove rows without an observation
    clean_sunspot_data = remove_nulls_and_no_obs(df, not_null_col)
    
    return clean_sunspot_data