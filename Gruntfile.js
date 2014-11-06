module.exports = function(grunt) {
	grunt.initConfig({
		coffee: {
            debug: {
                options: {
                    sourceMap: true
                },
                files: [{
                    expand: true,
                    cwd: "debug/lib/",
                    src: ["*.coffee", "**/*.coffee"],
                    dest: "debug/lib/",
                    ext: ".js"
                }]
            },

            release: {
                options: {
                    sourceMap: false
                },
                files: [{
                    expand: true,
                    cwd: "src/lib/",
                    src: ["*.coffee", "**/*.coffee"],
                    dest: "dist/lib/",
                    ext: ".js"
                }]
            }
        },

        copy: {
            debug: {
                files: [{
                    expand: true,
                    cwd: "src/lib/",
                    src: ["*.js", "*.coffee", "**/*.coffee"],
                    dest: "debug/lib/"
                }, {
                    expand: true,
                    cwd: "src/resources/",
                    src: ["*"],
                    dest: "debug/resources/"
                }]
            },

            debugWS: {
                files: [{
                    expand: true,
                    cwd: "src/lib/",
                    src: ["*.js"],
                    dest: "debug/lib/"
                }, {
                    expand: true,
                    cwd: "src/resources/",
                    src: ["*"],
                    dest: "debug/resources/"
                }]
            },

            release: {
                files: [{
                    expand: true,
                    cwd: "src/lib/",
                    src: ["*.js"],
                    dest: "dist/lib/"
                }, {
                    expand: true,
                    cwd: "src/resources/",
                    src: ["*"],
                    dest: "dist/resources/"
                }]
            }
        },

        stylus: {
            debug: {
                options: {
                    compress: false,
                    paths: ["src/stylus/"],
                    import: ["common.styl"]
                },
                files: [{
                    expand: true,
                    cwd: "src/stylus/",
                    src: ["*.styl", "!common.styl"],
                    dest: "debug/css",
                    ext: ".css"
                }]
            },

            release: {
                options: {
                    compress: true,
                    paths: ["src/stylus/"],
                    import: ["common.styl"]
                },
                files: [{
                    expand: true,
                    cwd: "src/stylus/",
                    src: ["*.styl", "!common.styl"],
                    dest: "dist/css",
                    ext: ".css"
                }]
            }
        },

        jade: {
            debug: {
                options: {
                    pretty: true,
                    data: {
                        base_ref: "/80x86Script/index.html",
                        env: "DEBUG"
                    }
                },
                files: [{
                    expand: true,
                    cwd: "src/",
                    src: ["*.jade", "**/*.jade"],
                    dest: "debug/",
                    ext: ".html"
                }]
            },

            release: {
                options: {
                    pretty: false,
                    data: {
                        base_ref: "/80x86Script/index.html",
                        env: "PROD"
                    }
                },
                files: [{
                    expand: true,
                    cwd: "src/",
                    src: ["*.jade", "**/*.jade"],
                    dest: "dist/",
                    ext: ".html"
                }]
            }
        },

        requirejs: {
            release: {
                options: {
                    baseUrl: "dist/lib/",
                    mainConfigFile: "dist/lib/main.js",
                    keepBuildDir: true,
                    optimize: "uglify2",
                    generateSourceMaps: false,
                    findNestedDependencies: true,
                    almond: true,
                    replaceRequireScript: [{
                        files: ["dist/index.html"],
                        module: "app"
                    }],
                    name: "main",
                    out: "dist/app.js"
                }
            }
        },

        clean: {
            postRelease: ["dist/lib"]
        },

        watch: {
            coffeeDebug: {
                files: ["debug/lib/*.coffee", "debug/lib/**/*.coffee"],
                tasks: ["coffee:debug"]
            },
            copyDebug: {
                files: ["src/lib/*.js", "src/lib/*.coffee", "src/lib/**/*.coffee", "src/resources/*"],
                tasks: ["copy:debug"]
            },
            copyDebugWS: {
                files: ["src/lib/*.js", "src/resources/*"],
                tasks: ["copy:debugWS"]
            },
            stylusDebug: {
                files: ["src/stylus/*.styl"],
                tasks: ["stylus:debug"]
            },
            jadeDebug: {
                files: ["src/*.jade", "src/**/*.jade"],
                tasks: ["jade:debug"]
            }
        }
	});

    grunt.loadNpmTasks("grunt-contrib-clean");
    grunt.loadNpmTasks("grunt-contrib-coffee");
    grunt.loadNpmTasks("grunt-contrib-copy");
    grunt.loadNpmTasks("grunt-contrib-jade");
    grunt.loadNpmTasks("grunt-contrib-stylus");
    grunt.loadNpmTasks("grunt-contrib-watch");
    grunt.loadNpmTasks("grunt-requirejs");

    grunt.registerTask("debug", ["copy:debug", "coffee:debug", "stylus:debug", "jade:debug"]);
    grunt.registerTask("release", ["jade:release", "stylus:release", "coffee:release", "copy:release", "requirejs:release", "clean:postRelease"]);
    grunt.registerTask("default", ["release"]);
};
