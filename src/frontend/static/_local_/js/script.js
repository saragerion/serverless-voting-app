function getLocalStorageVoteKey(videoId) {
  return "vote_" + videoId;
}

function showLoginButton() {
  const loader = document.getElementById("loader");
  loader.style.display = "none";
  let title = document.getElementById("title");
  const loginButton = "<a id='login-button' href='https://dev-7499450.okta.com/oauth2/default/v1/authorize?client_id=0oan3zrraSw254i2B5d5&response_type=token&scope=openid&redirect_uri=https://d1nmd3ycyktnbq.cloudfront.net/callback&state=state-296bc9a0-a2a2-4a57-be1a-d0e2fd9bb601&nonce="+ Date.now()+"'>Login with your Identity Provider</a>";
  title.insertAdjacentHTML("afterend", loginButton);
}

function loadData() {

  const accessToken = localStorage.getItem("accessToken");
  if (!accessToken) {
    showLoginButton();

    return;
  }

  const loader = document.getElementById("loader");
  loader.style.display = "block";

  const xhr = new XMLHttpRequest();
  xhr.open("get", "/api/videos", true);
  xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
  xhr.setRequestHeader("Authorization", "Bearer " + accessToken);
  xhr.send();

  xhr.onreadystatechange = function () {
    if (this.readyState == 4 && this.status == 200) {
      const response = JSON.parse(this.responseText);
      const responseData = response.data;
      console.log("DATA", response.data);

      loader.style.display = "none";
      for (let i = 0; i < responseData.length; i++) {
        const videoId = "video_" + i;
        let video = "<video-js id=\"" + videoId + "\" class=\"vjs-default-skin\" controls preload=\"auto\" width=\"640\" height=\"268\"><source src=\"" + responseData[i]["url"] + "\"  type=\"application/x-mpegURL\"></video-js>";
        video += "<div class='btn-group'>";
        video += "<a class='btn downvote' decision='downvote' video-id=" + responseData[i]["id"] + "><i class=\"far fa-thumbs-down\"></i><span>" + responseData[i]["downvotes"] + "</span></a>";
        video += "<a class='btn upvote' decision='upvote' video-id=" + responseData[i]["id"] + "><i class=\"far fa-thumbs-up\"></i><span>" + responseData[i]["upvotes"] + "</span></a>";
        video += "</div>";
        video += "<h2>" + responseData[i]["title"] + "</h2><h3>" + responseData[i]["description"] + "</h3>";
        let title = document.getElementById("title");
        title.insertAdjacentHTML("afterend", video);
        videojs(videoId);
      }

      registerVoteSubmission();
    } else if (this.readyState == 4 && this.status == 401) {
      showLoginButton();

      return;
    }

  };
}

function getVoteSubmission(localStorageVoteKey) {
  console.log("LOCAL STORAGE", localStorage.getItem(localStorageVoteKey));

  return localStorage.getItem(localStorageVoteKey);
}

function highlightButton(button) {
  button.classList.add("highlight");

}

function disableSubmittedVoteButtons(videoId) {
  const votedVideoButtons = document.querySelectorAll("a[video-id=\""+ videoId +"\"]");
  for (let i = 0; i < votedVideoButtons.length; i++) {
    votedVideoButtons[i].classList.add("inactive");
  }
}

function addEventListeners(buttons) {
  for (let i = 0; i < buttons.length; i++) {
    const button = buttons[i];
    const videoId = button.getAttribute("video-id");
    const decision = button.getAttribute("decision");
    const localStorageVoteKey = getLocalStorageVoteKey(videoId);
    const previousVote = getVoteSubmission(localStorageVoteKey);
    if (previousVote) {
      disableSubmittedVoteButtons(videoId);
      console.log("decision", previousVote, decision);
      if (previousVote === decision) {
        highlightButton(button);
      }
      continue;
    }

    button.addEventListener("click", (event) => {
      event.preventDefault();
      console.log("EVENT", event);
      console.log("EVENT TARGET", event.currentTarget);
      const videoId = button.getAttribute("video-id");
      const decision = button.getAttribute("decision");
      const localStorageVoteKey = getLocalStorageVoteKey(videoId);
      if (getVoteSubmission(localStorageVoteKey)) {
        disableSubmittedVoteButtons(videoId);

        return;
      }

      // Increment number in the UI
      const votesElement = event.currentTarget.querySelector("span");
      let currentVotes = parseInt(votesElement.innerText);
      console.log("currentVotes", currentVotes);
      currentVotes++;
      votesElement.innerText = currentVotes.toString();

      // Store submission in the local storage
      localStorage.setItem(localStorageVoteKey, decision);
      disableSubmittedVoteButtons(videoId);
      highlightButton(button);

      // Submit vote
      const xhr = new XMLHttpRequest();
      xhr.open("post", "/api/votes", true);
      xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
      const accessToken = localStorage.getItem("accessToken");
      xhr.setRequestHeader("Authorization", "Bearer " + accessToken);
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
}

function registerVoteSubmission() {
  const xhrUpvoteButtons = document.querySelectorAll("a.upvote");
  const xhrDownvoteButtons = document.querySelectorAll("a.downvote");

  addEventListeners(xhrUpvoteButtons);
  addEventListeners(xhrDownvoteButtons);
}

function submitCurrentOktaCode() {
  if (window.location.pathname.startsWith("/callback")) {

    const hash = window.location.hash.substr(1);
    const queryParams = hash.split("&").reduce((res, item) => {
      const parts = item.split("=");
      res[parts[0]] = parts[1];

      return res;
    }, {});

    const token = queryParams["access_token"];
    console.log("CODE", token);
    localStorage.setItem("accessToken", token);
    console.log("CALLBACK URL", window.location.href);
    window.history.replaceState({}, document.title, "/");
  }
}

let localStorage = window.localStorage;

submitCurrentOktaCode();
loadData();

