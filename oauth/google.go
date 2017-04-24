package oauth

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"math/rand"
	"sync"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

var (
	googleEndpoint = google.Endpoint
	userInfoURL    = "https://www.googleapis.com/oauth2/v3/userinfo"
	scopes         = []string{
		"https://www.googleapis.com/auth/userinfo.email",
	}
)

type GoogleService struct {
	config oauth2.Config

	stateMutex sync.Locker
	state      map[string]struct{}
}

type User struct {
	ID    string `json:"sub"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

func NewGoogleService(configPath string) (*GoogleService, error) {
	c, err := ioutil.ReadFile(configPath)
	if err != nil {
		return nil, err
	}

	var creds struct {
		ClientID     string `json:"client_id"`
		ClientSecret string `json:"client_secret"`
		RedirectURL  string `json:"redirect_url"`
	}
	err = json.Unmarshal(c, &creds)
	if err != nil {
		return nil, err
	}

	return &GoogleService{
		config: oauth2.Config{
			ClientID:     creds.ClientID,
			ClientSecret: creds.ClientSecret,
			RedirectURL:  creds.RedirectURL,
			Scopes:       scopes,
			Endpoint:     googleEndpoint,
		},

		stateMutex: &sync.RWMutex{},
		state:      make(map[string]struct{}),
	}, nil
}

func (c *GoogleService) LoginURL() string {
	s := randToken()
	c.stateMutex.Lock()
	c.state[s] = struct{}{}
	c.stateMutex.Unlock()

	return c.config.AuthCodeURL(s)
}

func (c *GoogleService) Login(state, code string) (*User, error) {
	c.stateMutex.Lock()
	_, ok := c.state[state]
	c.stateMutex.Unlock() // no defer because the token exchange could be long

	if !ok {
		return nil, errors.New("Invalid state")
	}

	c.stateMutex.Lock()
	delete(c.state, state)
	c.stateMutex.Unlock()

	tok, err := c.config.Exchange(oauth2.NoContext, code)
	if err != nil {
		return nil, err
	}

	user, err := c.retrieveUser(tok)
	if err != nil {
		return nil, err
	}

	// @TODO: call auth to upsert user and return it instead of this google user

	return user, nil
}

func (c *GoogleService) retrieveUser(tok *oauth2.Token) (*User, error) {
	client := c.config.Client(oauth2.NoContext, tok)
	res, err := client.Get(userInfoURL)
	if err != nil {
		return nil, err
	}

	defer res.Body.Close()

	var user User
	if err := json.NewDecoder(res.Body).Decode(&user); err != nil {
		return nil, err
	}

	return &user, nil
}

func randToken() string {
	b := make([]byte, 32)
	rand.Read(b)
	return base64.StdEncoding.EncodeToString(b)
}
