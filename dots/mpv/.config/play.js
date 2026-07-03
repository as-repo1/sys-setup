#!/usr/bin/env node
// ==============================================================================
// play.js
// Location: ~/.config/mpv/play.js (or in your project folder)
// Node-based CLI launcher for mpv + VapourSynth that cleans the python environment
// to avoid conflicts with virtualenv / Conda.
// ==============================================================================

const { spawn } = require('child_process');
const path = require('path');

const videoPath = process.argv[2];
if (!videoPath) {
    console.log('Usage: node play.js <path_to_video>');
    process.exit(1);
}

// Absolute path to the VapourSynth script
const scriptPath = path.resolve('/home/chaos/.config/mpv/svpflow_interpolation.vpy');

// Clean the environment block for mpv
const cleanEnv = { ...process.env };
if (cleanEnv.PATH) {
    // Strip active Python virtualenv ('nothing') and Anaconda ('miniconda3') from PATH
    cleanEnv.PATH = cleanEnv.PATH.split(path.delimiter)
        .filter(p => !p.includes('nothing') && !p.includes('miniconda3'))
        .join(path.delimiter);
}

// Remove Python environment controls to prevent loader conflicts
delete cleanEnv.PYTHONPATH;
delete cleanEnv.PYTHONHOME;
delete cleanEnv.VIRTUAL_ENV;

// mpv CLI args matching your system setup
const mpvArgs = [
    `--vf=vapoursynth="${scriptPath}":buffered-frames=4:concurrent-frames=4`,
    '--hwdec=vaapi-copy',
    '--vo=gpu',
    '--gpu-api=opengl',
    '--video-sync=display-resample',
    '--interpolation=no',
    '--keep-open=yes',
    videoPath
];

console.log(`Launching mpv: mpv ${mpvArgs.join(' ')}\n`);

const mpvProcess = spawn('mpv', mpvArgs, {
    env: cleanEnv,
    stdio: 'inherit' // Pipes output directly to your current terminal
});

mpvProcess.on('close', (code) => {
    console.log(`\nmpv process exited with code ${code}`);
});
