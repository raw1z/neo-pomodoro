exports.files = {
  javascripts: {joinTo: 'app.js'},
  stylesheets: {joinTo: 'app.css'}
};

exports.paths = {
  watched: ['app']
}

exports.plugins = {
  sass: {
    mode: 'ruby'
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

