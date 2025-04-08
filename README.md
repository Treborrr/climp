# Chaufa 🎶

A simple, elegant music control center for your Linux terminal.
Control your favorite music services like Spotify, YouTube, SoundCloud, and more — directly from your terminal.

Chaufa is served! 🍚🍳🔥

## Features

- Live music info display
- Compatible with browser-based music (YouTube, SoundCloud) and desktop apps
- Playback control (Play/Pause, Next, Previous, Volume control)
- Custom image display (user-defined)
- Clean, minimal terminal interface
- Automatic track updates

## Requirements

Chaufa uses the following tools:
- `playerctl`
- `chafa`
- `curl`

The installer will automatically handle dependencies for you.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/chaufa.git
cd chaufa
```

2. Run the installer:

```bash
bash install.sh
```

3. Start the control center:

```bash
chaufa
```

If you see `command not found`, make sure your local bin is in your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

Once running, use the following keys to control your music:

```
[P] Play/Pause
[N] Next track
[B] Previous track
[+] Increase volume
[-] Decrease volume
[S] Mute
[Q] Quit
```

Chaufa will automatically update as your track changes.

## Customization

You can change the image displayed in the terminal by editing the image URL inside the script:

1. Open the script:
```bash
nano ~/.local/bin/chaufa
```

2. Find this line:
```bash
IMAGE_URL="https://your-custom-image-url.com/image.png"
```

3. Replace the URL with your desired image.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Chaufa is served! 🍚🔥
