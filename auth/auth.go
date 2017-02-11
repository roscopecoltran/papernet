package auth

import (
	"context"
	"net/http"
	"strings"

	"github.com/bobinette/papernet"
	"github.com/bobinette/papernet/errors"
)

type Authenticator struct {
	Decoder TokenDecoder
	Store   papernet.UserRepository
}

func (a *Authenticator) Authenticate(next papernet.HandlerFunc) papernet.HandlerFunc {
	return func(req *papernet.Request) (interface{}, error) {
		token := req.Header.Get("Authorization")
		if len(token) <= 6 || strings.ToLower(token[:7]) != "bearer " {
			return nil, errors.New("no token found", errors.WithCode(http.StatusUnauthorized))
		}

		userID, err := a.Decoder.Decode(token[7:])
		if err != nil {
			return nil, errors.New("invalid token", errors.WithCode(http.StatusUnauthorized), errors.WithCause(err))
		}

		user, err := a.Store.Get(userID)
		if err != nil {
			return nil, errors.New("could not get user", errors.WithCause(err))
		} else if user == nil {
			return nil, errors.New("unknown user", errors.WithCode(http.StatusUnauthorized))
		}

		return next(req.WithContext(context.WithValue(req.Context(), "user", user)))
	}
}

func UserFromContext(ctx context.Context) (*papernet.User, error) {
	u := ctx.Value("user")
	if u == nil {
		return nil, errors.New("could not extract user", errors.WithCode(http.StatusUnauthorized))
	}

	user, ok := u.(*papernet.User)
	if !ok {
		return nil, errors.New("could not retrieve user", errors.WithCode(http.StatusUnauthorized))
	}

	return user, nil
}
