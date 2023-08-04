package kv

import (
	"context"
	"time"

	"github.com/sahib/misc/katta/segment"
)

type Merger struct {
	ctx    context.Context
	cancel func()
}

func NewMerger(ctx context.Context, r *segment.Registry) *Merger {
	ctx, cancel := context.WithCancel(ctx)
	return &Merger{
		ctx:    ctx,
		cancel: cancel,
	}
}

func (m *Merger) loop() {
	tckr := time.NewTicker(5 * time.Minute)
	for {
		select {
		case <-tckr.C:
			m.merge()
		case <-m.ctx.Done():
			return
		}
	}
}

func (m *Merger) merge() {
}

func (m *Merger) Start() {
	go m.merge()
}

func (m *Merger) Stop() {
	m.cancel()
}
