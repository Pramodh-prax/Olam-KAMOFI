import { LightningElement, api } from 'lwc';

export default class Kam_progressBar extends LightningElement {
    @api progressText = '0';
    @api progress = 0;
    @api borderRadius = 0;

    @api progressBarHeight = 40;
    @api textColor = '#ececec';
    @api progressBackgroundColor = '#173e35';

    @api id = '';

    get progressWidth () {
        let _tempProgress = this.progress ? this.progress : -1;
        return `clip-path: inset(-2% -1% -2% ${_tempProgress}%);-webkit-clip-path: inset(-2% -1% -2% ${_tempProgress}%);`;
    }

    get progressBarStyle () {
        let cssStyle = `border-radius : ${this.borderRadius}${this.borderRadius.toString ().endsWith ('px') ? ';' : 'px;'}`;
        cssStyle += `height : ${this.progressBarHeight}${this.progressBarHeight.toString ().endsWith ('px') ? ';' : 'px;'}`;
        return cssStyle;
    }

    get progressBarTextStyle () {
        return `background:${this.progressBackgroundColor};`;
    }

    handleOnProgressBarClicked (event) {
        const cilckEvent = new CustomEvent('progressbarclicked', { detail: {id : this.id }});
        this.dispatchEvent(cilckEvent);
    }
}