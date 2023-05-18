"""
Sunspot Analysis Functions


"""
import pandas as pd
import sunspot_data_cleaning_functions as ss_clean


def monthly_averages(input_data):
    """
    This function calculates the monthly averages of the sunspot data. 
    It groups the data by month and year, calculates the mean daily sunspot number for that month and the sum of the no. of observations,
    renames the daily_total_sunspot_no column and then creates a new datetime column of month-year
    
    Parameters
    ----------
    input_data: a dataframe of the sunspot data
    
    Returns
    -------
    df: the new dataframe with updated columns with daily_total_sunspot_number replaced with the monthly average values
    """
    
    # group by month and year, calculate monthly mean for daily sunspot number and sum for no. of observations
    aggregated_monthly = input_data.groupby(['year', 'month']).agg({'daily_total_sunspot_no': 'mean', 'no_of_obs':'sum'}).reset_index()
    
    # rename column
    aggregated_monthly.rename(columns = {'daily_total_sunspot_no':'monthly_mean_ssn'}, inplace = True)
    
    # recreate datetime column with month and year only 
    datetime_cols = ['month', 'year']
    monthly_ssn = ss_clean.create_datetime_column_flex(aggregated_monthly, datetime_cols)
    
    return monthly_ssn

def aggregated_average_ssn(input_data, groupby_values, agg_col_name):
    """
    This function is a more flexible version of monthly_averages, and will calculate the average by month or year.
    It groups data by the provided groupby_values, calculates the mean daily sunspot number for that period and the sum of the no. of observations,
    renames the daily_total_sunspot_no column and then creates a new datetime column
    
    Parameters
    ----------
    input_data: a dataframe of the sunspot data. 
    groupby_values: a list of the columns to groupby e.g. ['year', 'month']
    agg_col_name: a string of the new name of the daily_total_sunspot_no column
    
    Returns
    -------
    df: the new dataframe with updated columns with daily_total_sunspot_number replaced with the aggregated average values
    """
    
    # group by month and year, calculate monthly mean for daily sunspot number and sum for no. of observations
    aggregated_data = input_data.groupby(groupby_values).agg({'daily_total_sunspot_no': 'mean', 'no_of_obs':'sum'}).reset_index()
    
    # rename column
    aggregated_data.rename(columns = {'daily_total_sunspot_no': agg_col_name}, inplace = True)
    
    # recreate datetime column with month and year only 
    aggregated_data = ss_clean.create_datetime_column_flex(aggregated_data, groupby_values)
    
    return aggregated_data


