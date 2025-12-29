import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
} from '@nestjs/websockets';
import { Server } from 'socket.io';

@WebSocketGateway({
  cors: { origin: '*' },
})
export class EventsGateway {
  @WebSocketServer()
  server: Server;

  @SubscribeMessage('join_trip')
  handleJoinTrip(@MessageBody() data: { tripId: number }) {
    return { room: `trip-${data.tripId}` };
  }

  emitTripAccepted(tripId: number) {
    this.server.to(`trip-${tripId}`).emit('trip_status', {
      status: 'ACCEPTED',
    });
  }

  emitTripStarted(tripId: number) {
    this.server.to(`trip-${tripId}`).emit('trip_status', {
      status: 'STARTED',
    });
  }

  emitTripCompleted(tripId: number) {
    this.server.to(`trip-${tripId}`).emit('trip_status', {
      status: 'COMPLETED',
    });
  }

  // ======================
  // WEEK 6 EVENTS
  // ======================
  emitVoteRequest(tripId: number, vote: any) {
    this.server.to(`trip-${tripId}`).emit('vote_request', {
      voteId: vote.id,
      expiresAt: vote.expiresAt,
    });
  }

  emitVoteResult(tripId: number, result: 'APPROVED' | 'REJECTED' | 'EXPIRED') {
    this.server.to(`trip-${tripId}`).emit('vote_result', {
      result,
    });
  }
}
