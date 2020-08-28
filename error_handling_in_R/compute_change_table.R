compute_change_table <- function(input_data, group_col, time_col, comparison_col, start_time) {
  input_data$time_marker <- ifelse(input_data[,time_col] == start_time, -1, 1)
  input_data$comparison_marker <- input_data[,comparison_col]
  input_data$group_marker <- input_data[,group_col]
  return(input_data %>%
           dplyr::group_by(group_marker) %>%
           summarise(change = sum(comparison_marker * time_marker)))
}