import $ from 'jquery';
import vex from 'vex-js';
import bI18n from './i18n';

if (typeof vex === 'undefined') {
  throw new Error('You must include vex to use vex.dialog');
}

const $formToObject = ($form) => {
  const object = {};
  $.each($form.serializeArray(), function eachObj() {
    if (object[this.name]) {
      object[this.name] = (!object[this.name].push) ? [object[this.name]] : object[this.name];
      return object[this.name].push(this.value || '');
    }
    return object[this.name] = this.value || '';
  });
  return object;
};

const dialog = {};

dialog.buttons = {
  YES: {
    text: 'OK',
    type: 'submit',
    className: 'vex-dialog-button-primary',
  },
  NO: {
    text: 'Cancel',
    type: 'button',
    className: 'vex-dialog-button-secondary',
    click: ($vexContent) => {
      $vexContent.data().vex.value = false;
      return vex.close($vexContent.data().vex.id);
    },
  },
};

dialog.defaultOptions = {
  callback: () => {},
  afterOpen: () => {},
  message: 'Message',
  input: '<input name="vex" type="hidden" value="_vex-empty-value" />',
  value: false,
  buttons: [dialog.buttons.YES, dialog.buttons.NO],
  showCloseButton: false,
  onSubmit: function onSubmit(event) {
    const $form = $(this);
    const $vexContent = $form.parent();
    event.preventDefault();
    event.stopPropagation();
    $vexContent.data().vex.value = dialog.getFormValueOnSubmit($formToObject($form));
    return vex.close($vexContent.data().vex.id);
  },
  focusFirstInput: true,
};

dialog.defaultAlertOptions = {
  message: 'Alert',
  buttons: [dialog.buttons.YES],
};

dialog.defaultConfirmOptions = {
  message: 'Confirm',
};

dialog.open = (options) => {
  options = $.extend({}, vex.defaultOptions, dialog.defaultOptions, options);
  options.content = dialog.buildDialogForm(options);
  const beforeClose = options.beforeClose;
  options.beforeClose = ($vexContent, config) => {
    options.callback(config.value);
    return typeof beforeClose === 'function' ? beforeClose($vexContent, config) : void 0;
  };
  const $vexContent = vex.open(options);
  if (options.focusFirstInput) {
    $vexContent.find('button[type="submit"], button[type="button"], input[type="submit"], input[type="button"], textarea, input[type="date"], input[type="datetime"], input[type="datetime-local"], input[type="email"], input[type="month"], input[type="number"], input[type="password"], input[type="search"], input[type="tel"], input[type="text"], input[type="time"], input[type="url"], input[type="week"]').first().focus();
  }
  return $vexContent;
};

dialog.alert = (options) => {
  if (typeof options === 'string') {
    options = {
      message: options
    };
  }
  options = $.extend({}, dialog.defaultAlertOptions, options);
  return dialog.open(options);
};

dialog.confirm = (options) => {
  if (typeof options === 'string') {
    return $.error('dialog.confirm(options) requires options.callback.');
  }
  options = $.extend({}, dialog.defaultConfirmOptions, options);
  return dialog.open(options);
};

dialog.prompt = (options) => {
  if (typeof options === 'string') {
    return $.error('dialog.prompt(options) requires options.callback.');
  }
  const defaultPromptOptions = {
    message: '<label for="vex">' + (options.label || 'Prompt:') + '</label>',
    input: '<input name="vex" type="text" class="vex-dialog-prompt-input" placeholder="' + (options.placeholder || '') + '"  value="' + (options.value || '') + '" />'
  };
  options = $.extend({}, defaultPromptOptions, options);
  return dialog.open(options);
};

dialog.buildDialogForm = (options) => {
  const $form = $('<form class="vex-dialog-form" />');
  const $message = $('<div class="vex-dialog-message" />');
  const $input = $('<div class="vex-dialog-input" />');
  $form.append($message.append(options.message)).append($input.append(options.input)).append(dialog.buttonsToDOM(options.buttons)).bind('submit.vex', options.onSubmit);
  return $form;
};

dialog.getFormValueOnSubmit = (formData) => {
  if (formData.vex || formData.vex === '') {
    if (formData.vex === '_vex-empty-value') {
      return true;
    }
    return formData.vex;
  } else {
    return formData;
  }
};

dialog.buttonsToDOM = (buttons) => {
  const $buttons = $('<div class="vex-dialog-buttons" />');
  $.each(buttons, (index, button) => {
    const $button = $('<button type="' + button.type + '"></button>')
        .text(button.text)
        .addClass(button.className + ' vex-dialog-button ' + (index === 0 ? 'vex-first ' : '') + (index === buttons.length - 1 ? 'vex-last ' : ''))
        .bind('click.vex', function(e) {
          if (button.click) {
            return button.click(
              $(this).parents(vex.getSelectorFromBaseClass(vex.baseClassNames.content)), e
            );
          }
        });
    return $button.appendTo($buttons);
  });
  return $buttons;
};

vex.dialog = dialog;

class VexBrando {
  static setup() {
    // set default theme for vex dialogs
    vex.defaultOptions.className = 'vex-theme-plain';
    vex.dialog.buttons.YES.text = 'OK';
    vex.dialog.buttons.NO.text = bI18n.t('vex:cancel');
  }
}

export { VexBrando, vex };