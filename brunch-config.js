exports.files = {
  javascripts: {joinTo: 'app.js'},
  stylesheets: {joinTo: 'app.css'}
};

exports.paths = {
  watched: ['app']
}

exports.plugins = {
  sass: {
    precision: 8,
    options: {
      includePaths: ['node_modules/bootstrap/scss']
    }
  },

  elmBrunch: {
    outputFolder: 'public',
    outputFile: 'pomodoro.js'
  },

  postcss: {
    processors: [
      require('autoprefixer')(['last 8 versions']),
      require('csswring')()
    ]
  }
};

