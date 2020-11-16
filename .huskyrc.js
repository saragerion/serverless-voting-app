const tasks = t => t.join(' && ')

module.exports = {
    hooks: {
        'pre-commit': tasks([
            'npm run lint',
            'npm run build',
            'npm run test',
        ]),
        'commit-msg': tasks ( [
            './scripts/githooks.sh commit-msg'
        ])
    }
}
