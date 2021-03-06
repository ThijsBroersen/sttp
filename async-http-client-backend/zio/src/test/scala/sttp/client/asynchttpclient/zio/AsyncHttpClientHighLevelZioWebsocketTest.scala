package sttp.client.asynchttpclient.zio

import sttp.client._
import sttp.client.asynchttpclient.{AsyncHttpClientHighLevelWebsocketTest, WebSocketHandler}
import sttp.client.impl.zio.{RIOMonadAsyncError, convertZioIoToFuture, runtime}
import sttp.client.monad.MonadError
import sttp.client.testing.ConvertToFuture
import sttp.client.ws.WebSocket
import zio.clock.Clock
import zio.{Schedule, Task, ZIO}
import zio.duration._

import scala.concurrent.duration.FiniteDuration

class AsyncHttpClientHighLevelZioWebsocketTest extends AsyncHttpClientHighLevelWebsocketTest[Task] {
  override implicit val backend: SttpBackend[Task, Nothing, WebSocketHandler] =
    runtime.unsafeRun(AsyncHttpClientZioBackend())
  override implicit val convertToFuture: ConvertToFuture[Task] = convertZioIoToFuture
  override implicit val monad: MonadError[Task] = new RIOMonadAsyncError

  override def createHandler: Option[Int] => Task[WebSocketHandler[WebSocket[Task]]] =
    bufferCapacity => ZioWebSocketHandler(bufferCapacity)

  override def eventually[T](interval: FiniteDuration, attempts: Int)(f: => Task[T]): Task[T] = {
    ZIO.sleep(interval.toMillis.millis).andThen(f).retry(Schedule.recurs(attempts)).provideLayer(Clock.live)
  }
}
