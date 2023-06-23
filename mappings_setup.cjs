const fs = require("fs");
const os = require("os");
const path = require("path");

const config_path = path.join(os.homedir(), ".config/input-remapper");
const default_keyboard_name = "AT Translated Set 2 keyboard";
const default_preset_path = `${config_path}/presets/${default_keyboard_name}`;
const mappings_filename = "my_mappings.json";

const mappings_obj = {
    "mapping": {
        "1,125,1": [
            "Alt_L",
            "keyboard"
        ],
        "1,29,1": [
            "Super_L",
            "keyboard"
        ],
        "1,56,1": [
            "KEY_LEFTCTRL",
            "keyboard"
        ],
        "1,58,1": [
            "Escape",
            "keyboard"
        ],
        "1,1,1": [
            "Caps_Lock",
            "keyboard"
        ],
        "1,100,1": [
            "KEY_RIGHTCTRL",
            "keyboard"
        ],
        "1,97,1": [
            "Alt_R",
            "keyboard"
        ],
        "1,61,1": [
            "Control_L+KEY_F10",
            "keyboard"
        ]
    }
}

fs.mkdirSync(default_preset_path, { recursive: true });
fs.writeFileSync(`${default_preset_path}/${mappings_filename}`, JSON.stringify(mappings_obj, null, 4));

const default_config = (() => {
  try {
    return JSON.parse(fs.readFileSync(`${config_path}/config.json`).toString());
  } catch(e) {
    return {};
  }
})();

const config = {
  ...default_config,
  autoload: {
    [default_keyboard_name]: mappings_filename
  }
};

fs.writeFileSync(`${config_path}/config.json`, JSON.stringify(config, null, 4));

