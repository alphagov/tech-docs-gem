const { src, dest, series, parallel} = require('gulp');

const paths = {
  src: './source/',
  dist: './tmp/assets/govuk/',
  govuk_frontend: 'node_modules/govuk-frontend/dist/'
};
const copy = {
  govuk_frontend: {
    fonts: () => {
      return src(paths.govuk_frontend + 'govuk/assets/fonts/**/*')
        .pipe(dest(paths.dist + 'fonts/'));
    },
    images: () => {
      return src(paths.govuk_frontend + 'govuk/assets/images/**/*')
        .pipe(dest(paths.dist + 'images/'));
    },
    header_icon_manifest: () => {
      return src(paths.govuk_frontend + 'govuk/assets/manifest.json')
        .pipe(dest(paths.dist));
    },
  }
};


// Default: compile everything
const defaultTask = series(
  parallel(
    copy.govuk_frontend.fonts,
    copy.govuk_frontend.images,
    copy.govuk_frontend.header_icon_manifest,
  )
);


exports.default = defaultTask;