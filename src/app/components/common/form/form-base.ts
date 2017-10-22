import { FormBuilder, FormGroup } from '@angular/forms';
import { ControlsConfig } from './controls-config';


export abstract class FormBase {
    form: FormGroup;

    constructor(private fb: FormBuilder) {
    }

    createForm(controlsConfig?: ControlsConfig): void {
        this.form = this.fb.group(controlsConfig);
    }
}
