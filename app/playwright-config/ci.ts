import { PlaywrightTestConfig } from '@playwright/test';
import defaultConfig from './default';

const config: PlaywrightTestConfig = {
	...defaultConfig,
	webServer: {
		...defaultConfig.webServer,
		// build の成果物はキャッシュから取得する
		command: 'npm run preview'
	}
};

export default config;
