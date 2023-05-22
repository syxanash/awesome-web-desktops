import React, { useState, useEffect } from 'react';
import Helmet from 'react-helmet';

const loaderFrames = require.context('./loader', true);

const loaderAnimationInterval = 60;
const loaderIconFrames = 4;

function LoaderCursor () {
  const [frameIndex, setFrameIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setFrameIndex(previousValue => {
        return previousValue + 1;
      });
    }, loaderAnimationInterval);
    return () => {
      clearInterval(timer);
    };
  }, []);

  return (
    <Helmet>
      <style>
        {
          `
          * {
            cursor: url(${loaderFrames(`./frame${frameIndex % loaderIconFrames}.gif`)}), auto !important;
          }
          `
        }
      </style>
    </Helmet>
  );
}

export default LoaderCursor;
