function getCycleTimeChartData(url) {
  return $.getJSON(url).then(function(json){
    return convertToCycleTimeChartData(json);
  });
}

function convertToCycleTimeChartData(data) {
  var cycle_time_data = data.table.slice(1).reduce(function(memo, cycle_time_record){
    memo[0].push(cycle_time_record[3]);
    memo[1].push(cycle_time_record[4]);
    return memo;
  }, [['cycle_time_x'], ['cycle time']]);

  var regression_data = data.cycle_trendline.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  var moving_averages_data = data.cycle_averages.reduce(function(memo, average_record){
    memo[0].push(average_record[0]);
    memo[1].push(average_record[1]);
    return memo;
  }, [['moving_average_x'], ['moving average']]);

  return cycle_time_data.concat(regression_data).concat(moving_averages_data);
}

function convertToShortCycleTimeChartData(data) {
  var cycle_time_data = data.table.slice(1).reduce(function(memo, cycle_time_record){
    memo[0].push(cycle_time_record[2]);
    memo[1].push(cycle_time_record[5]);
    return memo;
  }, [['cycle_time_x'], ['cycle time']]);

  var regression_data = data.short_cycle_trendline.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  var moving_averages_data = data.short_cycle_averages.reduce(function(memo, average_record){
    memo[0].push(average_record[0]);
    memo[1].push(average_record[1]);
    return memo;
  }, [['moving_average_x'], ['moving average']]);

  return cycle_time_data.concat(regression_data).concat(moving_averages_data);
}

function convertToCycleTimeDeltaChartData(data) {
  var cycle_time_data = data.table.slice(1).reduce(function(memo, cycle_time_record){
    memo[0].push(cycle_time_record[3]);
    memo[1].push(cycle_time_record[6]);
    return memo;
  }, [['cycle_time_x'], ['cycle time delta']]);

  var regression_data = data.cycle_delta_trendline.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  var moving_averages_data = data.cycle_delta_averages.reduce(function(memo, average_record){
    memo[0].push(average_record[0]);
    memo[1].push(average_record[1]);
    return memo;
  }, [['moving_average_x'], ['moving average']]);

  return cycle_time_data.concat(regression_data).concat(moving_averages_data);
}

function getDeploymentChartData(url) {
  return $.getJSON(url).then(function(data){
    return convertToDeploymentChartData(data);
  });
}

function convertToDeploymentChartData(data) {
  var deployments = data.table.slice(1).reduce(function(memo, deployment_record){
    memo[0].push(deployment_record[0]);
    memo[1].push(deployment_record[1]);
    return memo;
  }, [['deployment_x'], ['deployments']]);

  var regression_data = data.regression.reduce(function(memo, regression_record){
    memo[0].push(regression_record[0]);
    memo[1].push(regression_record[1]);
    return memo;
  }, [['trendline_x'], ['trendline']]);

  return deployments.concat(regression_data);
}

function generateScatterPlot(chart_data, start_date, css_selector, variable_name) {
  xs = {};
  xs[variable_name] = 'cycle_time_x';
  xs['trendline'] = 'trendline_x';
  xs['moving average'] = 'moving_average_x';

  c3.generate({
    padding: {
       right: 40,
       left: 40
    },
    bindto: d3.select(css_selector),
    data: {
      xs: xs,
      columns: chart_data,
      type: 'scatter',
      types: {
        trendline: 'line',
        'moving average': 'line'
      }
    },
    axis: {
      y: {
        min: 0,
        padding: { top: 5, bottom:0 }
      },
      x: {
        min: Date.parse(start_date),
        type: 'timeseries',
        tick: {
         fit: true,
         count: 6,
         format: '%d-%m-%Y'
        }
      }
    },
    point: {
      r: 5,
      show: false
    }
  });
}
