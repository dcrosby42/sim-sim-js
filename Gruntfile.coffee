module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: '<json:package.json>'

    coffee:
      server:
        expand: true
        cwd: "src/server/sim_sim"
        src: ["**/*.coffee"]
        dest: "build"
        ext: ".js"
          
    # watch:
    #   files: [
    #     'src/client/**/*.coffee'
    #   ]
    #   tasks: ['shell:browserify_client']
    jasmine_node:
      options:
        forceExit: true
        match: '.'
        matchall: false
        extensions: 'coffee'
        specNameMatcher: 'spec'
        jUnit:
          report: true
          savePath : "./jasmine_build/reports/jasmine/"
          useDotNotation: true
          consolidate: true
      all: ['spec/']

    shell:
      server:
        command: "foreman start"
        options:
          stdout: true

      jasmine:
        command: "node_modules/jasmine-node/bin/jasmine-node --coffee spec/"
        options:
          stdout: true
          failOnError: true

      jasmine_watch:
        # command: "node_modules/jasmine-node/bin/jasmine-node --autotest --watch . --noStack --coffee spec/"
        command: "node_modules/jasmine-node/bin/jasmine-node --autotest --watch . --coffee spec/"
        options:
          stdout: true

      clean_build:
        command: "rm -rf build"
        options:
          stdout: true

      prepare_build:
        command: "mkdir -p build/client/sim_sim build/lib && cp package.json README.md LICENSE build"
        options:
          stdout: true

      browserify_client:
        command: "node_modules/.bin/browserify -t coffeeify src/client/sim_sim.coffee > build/client/sim_sim.js"
        options:
          failOnError: true
          stdout: true

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-jasmine-node'
  grunt.loadNpmTasks 'grunt-shell'

  # grunt.registerTask 'default', ['coffee:client']
  
  grunt.registerTask 'spec', ['jasmine_node']

  grunt.registerTask 'server', 'shell:server'
  grunt.registerTask 'test', 'shell:jasmine'
  grunt.registerTask 'wtest', 'shell:jasmine_watch'

  grunt.registerTask 'build', ['shell:clean_build', 'shell:prepare_build', 'shell:browserify_client', 'coffee:server']

