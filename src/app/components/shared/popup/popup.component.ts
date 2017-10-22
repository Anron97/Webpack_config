import { Component, EventEmitter, HostListener, Input, OnChanges, Output, SimpleChanges } from '@angular/core';
import { KeyCodes } from '../../../constants/KeyCodes';

@Component({
    selector: 'app-popup',
    templateUrl: 'popup.component.html',
    styleUrls: ['popup.component.scss']
})

export class PopupComponent implements OnChanges {
    @Input() closeRequest: boolean;
    @Output() onClose = new EventEmitter<void>();

    ngOnChanges(changes: SimpleChanges): void {
        if (changes.closeRequest.previousValue &&
            changes.closeRequest.previousValue !== changes.closeRequest.currentValue &&
            this.closeRequest) {
            this.closePopup();
        }
    }

    @HostListener('document:keydown', ['$event'])
    onEscapeTyped(event: KeyboardEvent): void {
        if (event.keyCode === KeyCodes.ESCAPE) {
            this.closePopup();
        }
    }

    closePopup(): void {
        this.onClose.emit();
    }
}
