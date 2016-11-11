'use strict';

const express = require('express');
const cookieParser = require('cookie-parser');
const app = express();
const request = require('request');
const cheerio = require('cheerio');
const SELECTORS_TO_REMOVE = [
  'script[src="//cdn.optimizely.com/js/4368606971.js"]',
  'link[href^="https://nav.bloomberg.com"]',
  'link[href^="https://www.bbthat.com"]',
  '.facemelter-container',
  '.bb-nav-placeholder',
  'nav'
].join(", ");

/**
 * Middleware
 */
app.use(express.static('public'));
app.use(cookieParser());

/**
 * Routes
 */
app.get('*', function (req, res) {
  request({
    url: `http://www.bloomberg.com${req.path}`,
  }, (error, response, body) => {
    if (error) {
      return res.send(error);
    }

    let $ = cheerio.load(body);
    $('<script src="/turbolinks.js"></script>').appendTo('head');
    $('a').each((index, link) => {
      const href = link.attribs.href;
      if (href) {
        link.attribs.href = href.replace(/http:\/\/www\.bloomberg\.com\//, '/');  
      }
    });
    $(SELECTORS_TO_REMOVE).remove();
    $('base').attr('href', 'http://localhost:9292');
    res.send($.html());
  });
});

/**
 * Start server
 */
let server = app.listen(process.env.PORT || 9292, function () {
  let host = server.address().address;
  let port = server.address().port;

  if (host === '::') {
    host = 'localhost';
  }

  console.log('Node.js app listening at http://%s:%s', host, port);
});
