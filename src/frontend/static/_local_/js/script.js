// OKTA VARIABLES

const oktaURL = 'https://_okta_org_name_._okta_base_url_/oauth2/default/v1';
const oktaClientID = '_okta_client_id_';
const oktaResponseType = 'code';
const oktaScope = 'openid';
const oktaRedirectURL = 'https://_cloudfront_distribution_alias_/callback';
const oktaState = 'state-296bc9a0-a2a2-4a57-be1a-d0e2fd9bb601';
const oktaNonce = Date.now();
const oktaCodeChallengeMethod = 'S256';
const oktaGrantType = 'authorization_code';
// TODO: these values should be changed
const oktaCodeChallenge = 'qjrzSW9gMiUgpUvqgEPE4_-8swvyCtfOVvg55o5S_es';
const oktaCodeVerifier = 'M25iVXpKU3puUjFaYWg3T1NDTDQtcW1ROUY5YXlwalNoc0hhakxifmZHag';

const getLocalStorageVoteKey = videoId => 'vote_' + videoId;

const showLoginButton = () => {
  const loader = document.getElementById('loader');
  loader.style.display = 'none';
  let title = document.getElementById('title');
  const loginButton = `<a id=\'login-button\' href=\'${oktaURL}/authorize?client_id=${oktaClientID}&response_type=${oktaResponseType}&scope=${oktaScope}&redirect_uri=${oktaRedirectURL}&state=${oktaState}&nonce=${oktaNonce}&code_challenge_method=${oktaCodeChallengeMethod}&code_challenge=${oktaCodeChallenge}\'>Login with your Identity Provider</a>`;
  title.insertAdjacentHTML('afterend', loginButton);
};

const loadData = () => {

  // const accessToken = localStorage.getItem('accessToken');
  // if (!accessToken) {
  //   showLoginButton();

  //   return;
  // }

  const loader = document.getElementById('loader');
  loader.style.display = 'block';

  const xhr = new XMLHttpRequest();
  xhr.open('get', '/api/videos', true);
  xhr.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
  // xhr.setRequestHeader('Authorization', 'Bearer ' + accessToken);
  xhr.send();

  xhr.onreadystatechange = function () {
    if (this.readyState == 4 && this.status == 200) {
      const response = JSON.parse(this.responseText);
      const responseData = response.data;
      console.log('DATA', response.data);

      updateRegion(response.region);

      loader.style.display = 'none';
      for (let i = 0; i < responseData.length; i++) {
        const videoId = 'video_' + i;
        let video = '<video-js id="' + videoId + '" class="vjs-default-skin" controls preload="auto" width="640" height="268"><source src="' + responseData[i]['url'] + '"  type="application/x-mpegURL"></video-js>';
        video += '<div class=\'btn-group\'>';
        video += '<a class=\'btn downvote\' decision=\'downvote\' video-id=' + responseData[i]['id'] + '><i class="far fa-thumbs-down"></i><span>' + responseData[i]['downvotes'] + '</span></a>';
        video += '<a class=\'btn upvote\' decision=\'upvote\' video-id=' + responseData[i]['id'] + '><i class="far fa-thumbs-up"></i><span>' + responseData[i]['upvotes'] + '</span></a>';
        video += '</div>';
        video += '<h2>' + responseData[i]['title'] + '</h2><h3>' + responseData[i]['description'] + '</h3>';
        let title = document.getElementById('title');
        title.insertAdjacentHTML('afterend', video);
        videojs(videoId);
      }

      registerVoteSubmission();
    } else if (this.readyState == 4 && this.status == 401) {
      // showLoginButton();
      alert('Received 401 response from backend');

      return;
    }

  };
};

const updateRegion = (regionName) => {
  const regionSpan = document.getElementById('region');
  regionSpan.innerText = regionName;
};

const registerVoteSubmission = () => {
  const xhrUpvoteButtons = document.querySelectorAll('a.upvote');
  const xhrDownvoteButtons = document.querySelectorAll('a.downvote');

  addEventListeners(xhrUpvoteButtons);
  addEventListeners(xhrDownvoteButtons);
};

const getVoteSubmission = localStorageVoteKey => {
  console.log('LOCAL STORAGE', localStorage.getItem(localStorageVoteKey));

  return localStorage.getItem(localStorageVoteKey);
};

const highlightButton = button => {
  button.classList.add('highlight');
};

const disableSubmittedVoteButtons = videoId => {
  const votedVideoButtons = document.querySelectorAll('a[video-id="'+ videoId +'"]');
  for (let i = 0; i < votedVideoButtons.length; i++) {
    votedVideoButtons[i].classList.add('inactive');
  }
};

const addEventListeners = function (buttons) {
  for (let i = 0; i < buttons.length; i++) {
    const button = buttons[i];
    const videoId = button.getAttribute('video-id');
    const decision = button.getAttribute('decision');
    const localStorageVoteKey = getLocalStorageVoteKey(videoId);
    const previousVote = getVoteSubmission(localStorageVoteKey);
    if (previousVote) {
      disableSubmittedVoteButtons(videoId);
      console.log('decision', previousVote, decision);
      if (previousVote === decision) {
        highlightButton(button);
      }
      continue;
    }

    button.addEventListener('click', (event) => {
      event.preventDefault();
      console.log('EVENT', event);
      console.log('EVENT TARGET', event.currentTarget);
      const videoId = button.getAttribute('video-id');
      const decision = button.getAttribute('decision');
      const localStorageVoteKey = getLocalStorageVoteKey(videoId);
      if (getVoteSubmission(localStorageVoteKey)) {
        disableSubmittedVoteButtons(videoId);

        return;
      }

      // Increment number in the UI
      const votesElement = event.currentTarget.querySelector('span');
      let currentVotes = parseInt(votesElement.innerText);
      console.log('currentVotes', currentVotes);
      currentVotes++;
      votesElement.innerText = currentVotes.toString();

      // Store submission in the local storage
      localStorage.setItem(localStorageVoteKey, decision);
      disableSubmittedVoteButtons(videoId);
      highlightButton(button);

      // Submit vote
      const xhr = new XMLHttpRequest();
      xhr.open('post', '/api/votes', true);
      xhr.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
      const accessToken = localStorage.getItem('accessToken');
      xhr.setRequestHeader('Authorization', 'Bearer ' + accessToken);
      const requestBody = {
        decision: decision,
        videoId: videoId
      };
      xhr.send(JSON.stringify(requestBody));

      xhr.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
          // Do stuff
        } else if (this.readyState == 4 && this.status == 401) {
          showLoginButton();
        }

      };
    });
  }
};

const authorizeApp = () => {
  if (window.location.pathname.startsWith('/callback')) {

    const queryParams = new Proxy(new URLSearchParams(window.location.search), {
      get: (searchParams, prop) => searchParams.get(prop),
    });

    console.log('queryParams', queryParams);
    const code = queryParams['code'];
    console.log('code', code);

    const xhr = new XMLHttpRequest();
    xhr.open('post', oktaURL+'/token', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.setRequestHeader('Cache-control', 'no-cache');
    xhr.setRequestHeader('Accept', 'application/json');
    const params = `code=${code}&grant_type=${oktaGrantType}&client_id=${oktaClientID}&redirect_uri=${oktaRedirectURL}&code_verifier=${oktaCodeVerifier}`;
    xhr.send(params);

    xhr.onreadystatechange = function () {
      if (this.readyState == 4 && this.status == 200) {
        const response = JSON.parse(this.responseText);
        console.log('response', response);
        const token = response.access_token;
        console.log('ACCESS_TOKEN', token);
        localStorage.setItem('accessToken', token);
        console.log('CALLBACK URL', window.location.href);
        window.history.replaceState({}, document.title, '/');
        loadData();
      } else if (this.readyState == 4 && this.status == 401) {
        showLoginButton();
      }

    };
  } else {
    loadData();
  }
};

// let localStorage = window.localStorage;
//
// authorizeApp();
console.log('loading data');
loadData();
