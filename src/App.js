import { useState, useCallback } from 'react';
import { ThemeProvider } from 'styled-components';
import {
  Window,
  WindowContent,
  ProgressBar,
  TextInput,
  Button,
} from 'react95';
import windowTheme from 'react95/dist/themes/raspberry';

import LoaderCursor from './LoaderCursor';

import styles from './page.module.css';

import blackCursor from './cursor.gif';
import logo from './logo.png';

function App() {
  const [percent, setPercent] = useState(0);
  const [unzipping, setUnzipping] = useState(false);

  const unzip = useCallback(() => {
    setUnzipping(true);

    const timer = setInterval(() => {
      setPercent(previousPercent => {
        if (previousPercent === 100) {
          window.location.replace('https://simone.computer/#/webdesktops');
          return previousPercent;
        }

        return previousPercent + 1;
      });
    }, 20 );
    return () => {
      clearInterval(timer);
    };
  }, []);

  const renderButtons = useCallback(() => {
    return <div className={styles.buttonWrapper}>
      <Button style={{ width: '120px', marginRight: '10px', cursor: `url(${blackCursor}), auto` }} size='md' onClick={() => window.location.replace('https://simone.computer')}>Cancel</Button>
      <Button style={{ width: '120px', cursor: `url(${blackCursor}), auto` }} primary size='md' onClick={unzip}>Ok</Button>
    </div>
  }, [unzip]);

  return <>
    <div id="mainwindow" className={styles.window}>
      <ThemeProvider theme={windowTheme}>
        <Window shadow={false} style={ { width: '100%', height: '100%' } }>
          <WindowContent>
            <div className={styles.headerError}>
              <div style={{ paddingTop: '15px', paddingBottom: '15px' }}>
                <img src={logo} alt='logo' />
                <span style={{ fontSize: '27px', position: 'absolute', top: '37px', left: '100px'}}>Pippo OS Archiver</span>
              </div>
            </div>
            <div style={{ paddingTop: '20px' }}>
              <div><h3>Unpack <span style={{ fontStyle: 'italic' }}>desktops.zip</span> to:</h3></div>
              <TextInput
                aria-label="directory"
                style={{ maxWidth: '330px' }}
                value={'simone.computer/#/webdesktops'}
              />
            </div>
            { unzipping ? <div style={{ paddingTop: '35px' }}><ProgressBar aria-label="progress" variant='tile' value={Math.floor(percent)} /></div> : null }
            { unzipping ? null : renderButtons() }
          </WindowContent>
        </Window>
      </ThemeProvider>
    </div>
    { unzipping ? <LoaderCursor /> : null }
  </>
}

export default App;
