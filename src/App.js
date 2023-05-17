import { useState, useEffect } from 'react';

import { ThemeProvider } from 'styled-components';

import {
  Window,
  WindowContent,
  ProgressBar,
  TextInput
} from 'react95';

import powershell from './powershell';
import styles from './page.module.css'

function App() {
  const [percent, setPercent] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setPercent(previousPercent => {
        if (previousPercent === 100) {
          // window.location.replace('https://simone.computer/#/webdesktops');
          clearInterval(timer);
        }
        const diff = Math.random() * 25;
        return Math.min(previousPercent + diff, 100);
      });
    }, 500);
    return () => {
      clearInterval(timer);
    };
  }, []);

  return <>
    <div className={styles.window}>
      <ThemeProvider theme={powershell}>
        <Window shadow={false} style={ { width: '100%' } }>
          <WindowContent>
            <div>
              <div className={styles.headerError}>
                <h2>
                  Pippo OS Archiver
                </h2>
              </div>
              <div style={{ paddingBottom: '50px', paddingTop: '20px' }}>
                <div><h3>Extracting desktops to:</h3></div>
                <TextInput
                  style={{ maxWidth: '300px' }}
                  value={'//simone.computer/#/webdesktops'}
                />
              </div>
              <ProgressBar variant='tile' value={Math.floor(percent)} />
            </div>
          </WindowContent>
        </Window>
      </ThemeProvider>
    </div>
  </>
}

export default App;
