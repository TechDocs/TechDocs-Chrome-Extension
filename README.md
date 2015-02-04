# TechDocs Chrome Extension

[TechDocs](https://github.com/TechDocs/TechDocs) is the technical document curation service for you. This Chrome extention provides the convenient switch between languages for the toolbar of your browser.

## Download

(coming soon!)


## Development

### Tools

- Node.js
- [SketchTool (Free)](http://bohemiancoding.com/sketch/tool/)

We're using [Sketch.app (Paid)](http://bohemiancoding.com/sketch/) for designing works, but it's not necessary for just building. To install SketchTool, run the script below.

```bash
$ curl -L https://raw.githubusercontent.com/cognitom/dotfiles/master/lib/sketchtool.sh | sudo sh
```

Are you a Windows user? SketchTool is just for Mac. Pls comment out [this line](https://github.com/TechDocs/TechDocs-Chrome-Extension/blob/master/gulpfile.coffee#L34).

### Build and Watch

Install dependencies.

```bash
$ npm install
```

Build the app.

```bash
$ gulp
```

Watch CofeeScript, CSS, ...etc

```bash
$ npm start
```

## Contributors

- [cognitom](https://github.com/cognitom/)
- [jetbee](https://github.com/jetbee)
- [kiki1980jp](https://github.com/kiki1980jp)
